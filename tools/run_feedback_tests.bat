@echo off
echo Running Feedback Coordination Integration Tests...
echo.
C:\Godot\Godot_v4.3-stable_win64.exe --path "%~dp0.." --headless res://scenes/test_feedback_coordination.tscn
echo.
echo Tests complete.
pause
