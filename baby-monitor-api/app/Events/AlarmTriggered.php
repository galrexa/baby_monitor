<?php
// app/Events/AlarmTriggered.php
namespace App\Events;

use App\Models\Alarm;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AlarmTriggered implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $alarm;

    public function __construct(Alarm $alarm)
    {
        $this->alarm = $alarm;
    }

    public function broadcastOn()
    {
        return [
            new Channel('room.' . $this->alarm->room_id),
            new Channel('caretakers'), // Global channel for all caretakers
        ];
    }

    public function broadcastAs()
    {
        return 'alarm.triggered';
    }

    public function broadcastWith()
    {
        return [
            'alarm' => $this->alarm,
            'room' => $this->alarm->room,
            'parent' => $this->alarm->parent,
        ];
    }
}