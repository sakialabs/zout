@echo off
echo ========================================
echo Running All Zout Tests
echo ========================================
echo.

echo [1/3] Running Data Model Integrity Property Test...
echo.
"C:\Godot\Godot_v4.3-stable_win64.exe" --path . --headless res://scenes/test_data_model_integrity.tscn
echo.

echo [2/3] Running Scene Initialization Unit Tests...
echo.
"C:\Godot\Godot_v4.3-stable_win64.exe" --path . --headless res://scenes/test_scene_initialization.tscn
echo.

echo [3/3] Running Feedback Coordination Integration Tests...
echo.
"C:\Godot\Godot_v4.3-stable_win64.exe" --path . --headless res://scenes/test_feedback_coordination.tscn
echo.

echo ========================================
echo All tests complete!
echo ========================================
pause
