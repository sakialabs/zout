# Scenes

This directory contains all Godot scene files (.tscn) for Zout.

## Main Scenes

### `practice_mode.tscn`

**The main playable scene for Practice Mode.**

Contains:

- Pitch surface (MeshInstance3D with collision)
- Goal with detection area (Area3D)
- Ball with physics (RigidBody3D, mass 0.43kg)
- Camera positioned behind ball
- Lighting (DirectionalLight3D)
- Environment (WorldEnvironment)
- All game systems attached as scripts

**How to play:**

1. Open in Godot Editor
2. Press F5 to run
3. Use WASD/Arrows to aim
4. Hold SPACE to charge power
5. Release SPACE to strike
6. Press R to reset

## Test Scenes

### `test_scene_initialization.tscn`

**Unit tests for scene loading and node structure.**

Tests:

- Scene loads within 3 seconds
- All required nodes exist with correct types

Run: `tools\run_scene_init_tests.bat`

### `test_feedback_coordination.tscn`

**Integration tests for feedback systems.**

Tests:

- All feedback systems trigger together for Zout
- Top Bins stacks on Zout correctly
- Feedback timing relationships

Run: `tools\run_feedback_tests.bat`

### `test_data_model_integrity.tscn`

**Property-based test for data model integrity.**

Tests:

- Strike execution preserves input parameters (100 random iterations)

Run: `tools\run_data_model_tests.bat`

## Validation Scenes

### `core_systems_validation.tscn`

**Manual validation scene for core strike mechanics.**

Used for testing:

- Complete strike flow (aim → charge → contact → flight → outcome)
- Contact quality effects on ball physics
- Goal detection accuracy
- Reset functionality

Run manually in Godot Editor to test "feel" of mechanics.

### `strike_flow_validation.tscn`

**Focused validation for strike state machine.**

Tests state transitions:

- READY → AIMING → CHARGING → CONTACT → FLIGHT → OUTCOME → RESET

## Scene Structure

All scenes follow Godot's node hierarchy:

```plaintext
Root Node (Node or Node3D)
├── Visual Elements (MeshInstance3D)
├── Physics Bodies (RigidBody3D, StaticBody3D)
├── Detection Areas (Area3D)
├── Camera (Camera3D)
├── Lighting (DirectionalLight3D)
├── Environment (WorldEnvironment)
└── Scripts (attached to appropriate nodes)
```

## File Format

All scenes use Godot 4.3's text-based scene format (.tscn) for version control friendliness.

## Opening Scenes

**In Godot Editor:**

1. Double-click the .tscn file in the FileSystem panel
2. Or: File → Open Scene → Select .tscn file

**Running Scenes:**

- Press F5 to run current scene
- Press F6 to run main scene (practice_mode.tscn)

## Creating New Scenes

When creating new scenes:

1. Use descriptive snake_case names
2. Add a comment at the top describing the scene's purpose
3. Organize nodes logically in the hierarchy
4. Attach scripts to the appropriate nodes
5. Save in this directory
