@echo off
echo Running Scene Initialization Tests...
echo.

REM Find Godot executable
set GODOT_PATH=C:\Godot\Godot_v4.3-stable_win64.exe

REM Check if Godot exists at the default path
if not exist "%GODOT_PATH%" (
    echo Godot not found at %GODOT_PATH%
    echo Please update GODOT_PATH in this script to point to your Godot executable
    pause
    exit /b 1
)

REM Run the test scene
"%GODOT_PATH%" --path "%~dp0.." --headless res://scenes/test_scene_initialization.tscn

echo.
echo Tests complete!
pause
