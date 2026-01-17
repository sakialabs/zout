@echo off
echo Running Data Model Integrity Property Tests...
echo.

REM Run the test scene in headless mode
"C:\Godot\Godot_v4.3-stable_win64.exe" --path . --headless res://scenes/test_data_model_integrity.tscn

echo.
echo Tests complete.
pause
