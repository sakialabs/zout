@echo off
REM Run all core mechanic unit tests
REM This runs the newly implemented test suite for Tasks 3.1, 3.2, 4.1, 5.1, and 6.1

echo.
echo ================================================
echo ZOUT - Core Mechanics Test Suite
echo ================================================
echo Running all unit and property tests...
echo.

set GODOT_PATH="C:\Program Files\Godot\Godot_v4.3-stable_win64.exe"
set PROJECT_PATH=%~dp0..

if not exist %GODOT_PATH% (
    echo ERROR: Godot executable not found at %GODOT_PATH%
    echo Please update GODOT_PATH in this script to point to your Godot installation
    pause
    exit /b 1
)

REM Track test results
set TOTAL_TESTS=0
set PASSED_TESTS=0

REM Test 1: Timing Windows
echo.
echo [1/5] Running Timing Windows Unit Tests...
echo ================================================
%GODOT_PATH% --headless --path "%PROJECT_PATH%" res://tests/scenes/test_timing_windows.tscn
set /A TOTAL_TESTS+=1
if %ERRORLEVEL% EQU 0 (set /A PASSED_TESTS+=1)

REM Test 2: Contact Quality Consistency
echo.
echo [2/5] Running Contact Quality Property Tests...
echo ================================================
%GODOT_PATH% --headless --path "%PROJECT_PATH%" res://tests/scenes/test_contact_quality_consistency.tscn
set /A TOTAL_TESTS+=1
if %ERRORLEVEL% EQU 0 (set /A PASSED_TESTS+=1)

REM Test 3: Aim Clamping
echo.
echo [3/5] Running Aim Clamping Unit Tests...
echo ================================================
%GODOT_PATH% --headless --path "%PROJECT_PATH%" res://tests/scenes/test_aim_clamping.tscn
set /A TOTAL_TESTS+=1
if %ERRORLEVEL% EQU 0 (set /A PASSED_TESTS+=1)

REM Test 4: Power Charging
echo.
echo [4/5] Running Power Charging Unit Tests...
echo ================================================
%GODOT_PATH% --headless --path "%PROJECT_PATH%" res://tests/scenes/test_power_charging.tscn
set /A TOTAL_TESTS+=1
if %ERRORLEVEL% EQU 0 (set /A PASSED_TESTS+=1)

REM Test 5: Timing Evaluation
echo.
echo [5/5] Running Timing Evaluation Unit Tests...
echo ================================================
%GODOT_PATH% --headless --path "%PROJECT_PATH%" res://tests/scenes/test_timing_evaluation.tscn
set /A TOTAL_TESTS+=1
if %ERRORLEVEL% EQU 0 (set /A PASSED_TESTS+=1)

REM Summary
echo.
echo ================================================
echo TEST SUITE SUMMARY
echo ================================================
echo Total Test Suites: %TOTAL_TESTS%
echo Passed: %PASSED_TESTS%
echo Failed: %FAILED_TESTS%
echo.

if %PASSED_TESTS% EQU %TOTAL_TESTS% (
    echo Result: ALL TESTS PASSED! 🎯
    echo.
    echo The core mechanics are validated and ready.
) else (
    echo Result: SOME TESTS FAILED ❌
    echo.
    echo Please review the test output above for details.
)

echo.
echo ================================================
pause
