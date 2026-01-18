@echo off
echo ========================================
echo Task 22: Manual Practice Mode Test
echo ========================================
echo.
echo Launching Practice Mode for manual testing...
echo.
echo Test the following:
echo   1. Multiple strikes work correctly
echo   2. Stats track across attempts
echo   3. Assists can be toggled (C for aim, T for trajectory)
echo   4. Reset works (R key)
echo   5. All systems coordinate seamlessly
echo   6. Practice mode feels calm, focused, repeatable
echo.
echo Controls:
echo   WASD/Arrows: Aim
echo   SPACE: Hold to charge power, release to strike
echo   R: Reset
echo   C: Toggle aim assist
echo   T: Toggle trajectory preview
echo   Tab: Toggle stats display
echo.
echo Press any key to launch...
pause > nul
"C:\Godot\Godot_v4.3-stable_win64.exe" --path . res://scenes/practice_mode.tscn
