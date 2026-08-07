<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\LeaveController;
use App\Http\Controllers\Api\ApprovalController;
use App\Http\Controllers\Api\ShiftController;
use App\Http\Controllers\Api\CompanyController;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    Route::prefix('device')->group(function () {
        Route::post('/register', [DeviceController::class, 'register']);
        Route::get('/status', [DeviceController::class, 'status']);
    });

    Route::prefix('attendance')->group(function () {
        Route::post('/enroll-face', [AttendanceController::class, 'enrollFace']);
        Route::post('/check-in', [AttendanceController::class, 'checkIn']);
        Route::post('/check-out', [AttendanceController::class, 'checkOut']);
        Route::get('/history', [AttendanceController::class, 'history']);
    });

    Route::prefix('leave')->group(function () {
        Route::get('/types', [LeaveController::class, 'types']);
        Route::get('/balances', [LeaveController::class, 'balances']);
        Route::get('/history', [LeaveController::class, 'history']);
        Route::post('/request', [LeaveController::class, 'request']);
    });

    Route::prefix('approvals')->group(function () {
        Route::get('/pending', [ApprovalController::class, 'pending']);
        Route::post('/{instance}/action', [ApprovalController::class, 'action']);
    });

    Route::get('/shifts/upcoming', [ShiftController::class, 'upcoming']);
    Route::get('/calendar', [CompanyController::class, 'calendar']);
    
    Route::prefix('announcements')->group(function () {
        Route::get('/', [CompanyController::class, 'announcements']);
        Route::post('/{announcement}/acknowledge', [CompanyController::class, 'acknowledgeAnnouncement']);
    });
});
