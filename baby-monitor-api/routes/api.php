<?php
// routes/api.php
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\AlarmController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::post('/fcm-token', [AuthController::class, 'updateFcmToken']);
    
    // Room routes
    Route::apiResource('rooms', RoomController::class);
    
    // Alarm routes
    Route::prefix('alarms')->group(function () {
        Route::get('/', [AlarmController::class, 'index']);
        Route::post('/trigger', [AlarmController::class, 'trigger']);
        Route::post('/{alarm}/acknowledge', [AlarmController::class, 'acknowledge']);
        Route::post('/{alarm}/reset', [AlarmController::class, 'reset']);
        Route::get('/active-for-caretaker', [AlarmController::class, 'getActiveForCaretaker']);
    });
    
    // User management (Admin only)
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('users', UserController::class);
        Route::post('/users/{user}/assign-rooms', [UserController::class, 'assignRooms']);
    });
});