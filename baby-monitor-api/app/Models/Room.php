<?php
// app/Models/Room.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'description', 'parent_id', 'is_active', 'custom_alarm_sound'
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Relationships
    public function parent()
    {
        return $this->belongsTo(User::class, 'parent_id');
    }

    public function caretakers()
    {
        return $this->belongsToMany(User::class)->where('role', 'caretaker');
    }

    public function alarms()
    {
        return $this->hasMany(Alarm::class);
    }

    public function activeAlarms()
    {
        return $this->hasMany(Alarm::class)->where('status', 'active');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}