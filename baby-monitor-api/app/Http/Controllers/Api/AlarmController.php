<?php
// app/Http/Controllers/Api/AlarmController.php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alarm;
use App\Models\Room;
use Illuminate\Http\Request;
use App\Events\AlarmTriggered;
use App\Events\AlarmAcknowledged;

class AlarmController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Alarm::with(['room', 'parent', 'acknowledgedByUser']);

        // Filter based on user role
        if ($user->role === 'parent') {
            $query->where('parent_id', $user->id);
        } elseif ($user->role === 'caretaker') {
            $query->whereHas('room.caretakers', function($q) use ($user) {
                $q->where('user_id', $user->id);
            });
        }

        // Filter by status if provided
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $alarms = $query->orderBy('triggered_at', 'desc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $alarms
        ]);
    }

    public function trigger(Request $request)
    {
        $request->validate([
            'room_id' => 'required|exists:rooms,id',
        ]);

        $room = Room::findOrFail($request->room_id);
        
        // Deactivate existing active alarms for this room
        Alarm::where('room_id', $room->id)
            ->where('status', 'active')
            ->update(['status' => 'inactive']);

        // Create new alarm
        $alarm = Alarm::create([
            'room_id' => $room->id,
            'parent_id' => $request->user()->id,
            'status' => 'active',
            'triggered_at' => now(),
        ]);

        // Broadcast alarm event
        event(new AlarmTriggered($alarm->load(['room', 'parent'])));

        return response()->json([
            'status' => 'success',
            'message' => 'Alarm triggered successfully',
            'data' => $alarm->load(['room', 'parent'])
        ], 201);
    }

    public function acknowledge(Request $request, Alarm $alarm)
    {
        $alarm->update([
            'status' => 'acknowledged',
            'acknowledged_at' => now(),
            'acknowledged_by' => $request->user()->id,
        ]);

        // Broadcast acknowledgment event
        event(new AlarmAcknowledged($alarm->load(['room', 'parent', 'acknowledgedByUser'])));

        return response()->json([
            'status' => 'success',
            'message' => 'Alarm acknowledged successfully',
            'data' => $alarm
        ]);
    }

    public function reset(Request $request, Alarm $alarm)
    {
        $alarm->update(['status' => 'inactive']);

        return response()->json([
            'status' => 'success',
            'message' => 'Alarm reset successfully',
            'data' => $alarm
        ]);
    }

    public function getActiveForCaretaker(Request $request)
    {
        $user = $request->user();
        
        $activeAlarms = Alarm::with(['room', 'parent'])
            ->whereHas('room.caretakers', function($q) use ($user) {
                $q->where('user_id', $user->id);
            })
            ->where('status', 'active')
            ->orderBy('triggered_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $activeAlarms
        ]);
    }
}