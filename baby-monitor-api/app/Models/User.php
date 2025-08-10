<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // Pastikan ini ada

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable; // Pastikan HasApiTokens ada

    protected $fillable = [
        'name', 'username', 'email', 'password', 'role', 'is_active', 'fcm_token', 'last_login'
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_login' => 'datetime',
        'is_active' => 'boolean',
    ];

    // Relationships
    public function rooms()
    {
        return $this->belongsToMany(Room::class);
    }

    public function parentRooms()
    {
        return $this->hasMany(Room::class, 'parent_id');
    }

    public function triggeredAlarms()
    {
        return $this->hasMany(Alarm::class, 'parent_id');
    }

    public function acknowledgedAlarms()
    {
        return $this->hasMany(Alarm::class, 'acknowledged_by');
    }

    // Scopes
    public function scopeCaretakers($query)
    {
        return $query->where('role', 'caretaker');
    }

    public function scopeParents($query)
    {
        return $query->where('role', 'parent');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}