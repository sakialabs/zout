@echo off
echo Opening Godot Editor for Zout Practice Mode...
echo.
echo Project Location: %~dp0
echo.
start "" "C:\Godot\Godot_v4.3-stable_win64.exe" --path "%~dp0" --editor
