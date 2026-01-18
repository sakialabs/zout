@echo off
REM Run timing windows unit tests
echo.
echo ================================================
echo Running Timing Windows Unit Tests
echo ================================================
echo.

set GODOT_PATH="C:\Program Files\Godot\Godot_v4.3-stable_win64.exe"
set PROJECT_PATH=%~dp0..
set TEST_SCENE=res://tests/scenes/test_timing_windows.tscn

if not exist %GODOT_PATH% (
    echo ERROR: Godot executable not found at %GODOT_PATH%
    echo Please update GODOT_PATH in this script to point to your Godot installation
    pause
    exit /b 1
)

%GODOT_PATH% --headless --path "%PROJECT_PATH%" %TEST_SCENE%

echo.
echo ================================================
echo Test execution complete
echo ================================================
pause
