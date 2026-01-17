@echo off
echo.
echo ========================================
echo   ZOUT PRACTICE MODE - Setup Verification
echo ========================================
echo.

echo Checking Godot installation...
if exist "C:\Godot\Godot_v4.3-stable_win64.exe" (
    echo [OK] Godot 4.3 found at C:\Godot\
) else (
    echo [ERROR] Godot not found at C:\Godot\
    echo Please run the download script first.
    pause
    exit /b 1
)

echo.
echo Checking project files...
if exist "project.godot" (
    echo [OK] project.godot found
) else (
    echo [ERROR] project.godot not found
    echo Make sure you're in the project directory
    pause
    exit /b 1
)

if exist "scenes\practice_mode.tscn" (
    echo [OK] practice_mode.tscn found
) else (
    echo [WARNING] practice_mode.tscn not found
)

echo.
echo Checking scripts...
set script_count=0
for %%f in (scripts\*.gd) do set /a script_count+=1
echo [OK] Found %script_count% GDScript files

echo.
echo ========================================
echo   Setup Status: READY!
echo ========================================
echo.
echo You can now:
echo   1. Double-click 'start.bat' to open the editor
echo   2. Or use 'tools\launch_godot.bat' to run the game
echo   3. Read 'docs\setup.md' for detailed instructions
echo.
echo Press F5 in the editor to run your game!
echo.
pause
