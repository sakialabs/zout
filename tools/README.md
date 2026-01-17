# Tools

This directory contains utility scripts and batch files for development and testing.

## Test Runners (Windows Batch Files)

### `run_all_tests.bat`
**Runs all automated tests in sequence.**

Executes:
1. Data model integrity property test (100 iterations)
2. Scene initialization unit tests
3. Feedback coordination integration tests

**Usage:** Double-click or run from command line
```bash
tools\run_all_tests.bat
```

### `run_data_model_tests.bat`
**Runs property-based test for data model integrity.**

Tests that StrikeData preserves input parameters exactly across 100 random iterations.

**Usage:**
```bash
tools\run_data_model_tests.bat
```

### `run_scene_init_tests.bat`
**Runs unit tests for scene initialization.**

Tests:
- Scene loads within 3 seconds
- All required nodes exist with correct types

**Usage:**
```bash
tools\run_scene_init_tests.bat
```

### `run_feedback_tests.bat`
**Runs integration tests for feedback coordination.**

Tests:
- All feedback systems trigger together
- Top Bins stacks correctly
- Timing relationships are correct

**Usage:**
```bash
tools\run_feedback_tests.bat
```

## Godot Launchers

### `launch_godot_editor.bat`
**Opens the project in Godot Editor.**

**Usage:** Double-click to open the editor
```bash
tools\launch_godot_editor.bat
```

### `launch_godot.bat`
**Runs the main game scene directly.**

**Usage:** Double-click to play the game
```bash
tools\launch_godot.bat
```

## Utility Scripts

### `create_placeholder_audio.gd`
**Godot script to generate placeholder audio files.**

Creates silent WAV files for all required audio assets when real audio isn't available yet.

**Usage:**
1. Open in Godot Editor
2. Attach to a Node in a scene
3. Run the scene
4. Check `audio/` folder for generated files

### `verify_setup.bat`
**Verifies project setup and dependencies.**

Checks:
- Godot installation path
- Required directories exist
- Scene files are present
- Script files are present

**Usage:**
```bash
tools\verify_setup.bat
```

## Creating New Tools

When adding new tools:
1. Use descriptive names (e.g., `run_[test_name]_tests.bat`)
2. Add echo statements for user feedback
3. Include error handling where appropriate
4. Document in this README
5. Test on a clean project setup

## Batch File Template

```batch
@echo off
echo Running [Tool Name]...
echo.

REM Your commands here
"C:\Godot\Godot_v4.3-stable_win64.exe" --path . --headless res://scenes/your_scene.tscn

echo.
echo [Tool Name] complete.
pause
```

## Notes

- All batch files assume Godot is installed at `C:\Godot\Godot_v4.3-stable_win64.exe`
- Modify the Godot path in batch files if your installation differs
- Tests run in headless mode (no window) for faster execution
- Exit code -1 is expected (Godot's normal exit code)
- Use `pause` at the end of batch files to keep the window open

## Cross-Platform Support

For Linux/Mac users, equivalent shell scripts can be created:

```bash
#!/bin/bash
echo "Running tests..."
/path/to/godot --path . --headless res://scenes/test_scene.tscn
```

Make executable with: `chmod +x script.sh`
