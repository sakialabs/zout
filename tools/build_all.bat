@echo off
REM Build and Package Script for Zout Practice Mode MVP
REM Task 28: Build and package

echo ============================================
echo ZOUT - BUILD AND PACKAGE
echo ============================================
echo.

REM Check if Godot is available
where godot >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Godot not found in PATH
    echo.
    echo Please add Godot to your PATH or edit this script to point to Godot executable
    echo Example: set GODOT_PATH=C:\Path\To\Godot_v4.x\godot.exe
    echo.
    pause
    exit /b 1
)

echo Found Godot in PATH
echo.

REM Create builds directory
if not exist "builds" mkdir builds
echo Created builds directory
echo.

REM Export for Windows
echo Building for Windows...
godot --headless --export-release "Windows Desktop" "builds/Zout_Windows.exe"
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Windows build complete
) else (
    echo   ✗ Windows build failed
)
echo.

REM Export for Linux
echo Building for Linux...
godot --headless --export-release "Linux/X11" "builds/Zout_Linux.x86_64"
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Linux build complete
) else (
    echo   ✗ Linux build failed
)
echo.

REM Export for macOS (if available)
echo Building for macOS...
godot --headless --export-release "macOS" "builds/Zout_macOS.zip"
if %ERRORLEVEL% EQU 0 (
    echo   ✓ macOS build complete
) else (
    echo   ✗ macOS build failed (may need macOS export template)
)
echo.

echo ============================================
echo BUILD COMPLETE
echo ============================================
echo.
echo Builds are in the 'builds' folder
echo.
echo Next steps:
echo   1. Test builds on target platforms
echo   2. Verify 60 FPS performance
echo   3. Create gameplay clip for sharing
echo.
pause
