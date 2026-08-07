<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceController;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    Route::prefix('device')->group(function () {
        Route::post('/register', [DeviceController::class, 'register']);
        Route::get('/status', [DeviceController::class, 'status']);
    });

    Route::prefix('attendance')->group(function () {
        Route::post('/enroll-face', [\App\Http\Controllers\Api\AttendanceController::class, 'enrollFace']);
        Route::post('/check-in', [\App\Http\Controllers\Api\AttendanceController::class, 'checkIn']);
        Route::post('/check-out', [\App\Http\Controllers\Api\AttendanceController::class, 'checkOut']);
        Route::get('/history', [\App\Http\Controllers\Api\AttendanceController::class, 'history']);
    });
});
