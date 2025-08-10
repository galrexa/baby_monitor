<?php
// app/Http/Controllers/Api/RoomController.php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\Request;

class RoomController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Room::with(['parent', 'caretakers'])->active();

        // Filter based on user role
        if ($user->role === 'parent') {
            $query->where('parent_id', $user->id);
        } elseif ($user->role === 'caretaker') {
            $query->whereHas('caretakers', function($q) use ($user) {
                $q->where('user_id', $user->id);
            });
        }

        $rooms = $query->get();

        return response()->json([
            'status' => 'success',
            'data' => $rooms
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'parent_id' => 'nullable|exists:users,id',
            'caretaker_ids' => 'nullable|array',
            'caretaker_ids.*' => 'exists:users,id',
        ]);

        $room = Room::create($request->only(['name', 'description', 'parent_id']));

        if ($request->has('caretaker_ids')) {
            $room->caretakers()->attach($request->caretaker_ids);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Room created successfully',
            'data' => $room->load(['parent', 'caretakers'])
        ], 201);
    }

    public function show(Room $room)
    {
        return response()->json([
            'status' => 'success',
            'data' => $room->load(['parent', 'caretakers', 'activeAlarms'])
        ]);
    }

    public function update(Request $request, Room $room)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'parent_id' => 'nullable|exists:users,id',
            'caretaker_ids' => 'nullable|array',
            'caretaker_ids.*' => 'exists:users,id',
        ]);

        $room->update($request->only(['name', 'description', 'parent_id']));

        if ($request->has('caretaker_ids')) {
            $room->caretakers()->sync($request->caretaker_ids);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Room updated successfully',
            'data' => $room->load(['parent', 'caretakers'])
        ]);
    }

    public function destroy(Room $room)
    {
        $room->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Room deleted successfully'
        ]);
    }
}