# Scripts

This directory contains all GDScript files for Zout.

## Core Systems

### Data Models
- **`strike_data.gd`** - Stores strike parameters (aim, power, timing, quality)
- **`outcome_data.gd`** - Stores strike results (goal status, Top Bins, points, entry position)
- **`session_stats.gd`** - Tracks session statistics (attempts, goals, streaks, score)

### Strike Mechanics
- **`strike_controller.gd`** - Main state machine coordinating the strike flow
- **`aim_system.gd`** - Handles aim input and direction calculation
- **`power_system.gd`** - Manages power charge timing and level
- **`timing_system.gd`** - Evaluates contact timing and determines quality
- **`contact_quality_calculator.gd`** - Calculates contact quality from timing/power

### Physics & Detection
- **`ball_physics.gd`** - Ball physics with quality-based drift effects
- **`goal_detector.gd`** - Detects goal line crossings and Top Bins zones

### Feedback Systems
- **`feedback_manager.gd`** - Coordinates all feedback (audio, camera, UI)
- **`audio_feedback.gd`** - Plays strike sounds, Zout calls, Top Bins audio
- **`camera_feedback.gd`** - Camera movement, shake, slowmo effects
- **`ui_feedback.gd`** - Power bar, score popups, stats display

### Practice Mode
- **`practice_mode.gd`** - Main practice mode loop with infinite attempts

## File Naming Convention

All scripts use snake_case naming (e.g., `strike_controller.gd`).

## Class Names

Scripts that define classes use `class_name` at the top:
```gdscript
class_name StrikeData
extends RefCounted
```

This allows them to be referenced from other scripts without preloading.

## Script Structure

Most scripts follow this structure:
1. Class declaration and extends
2. Documentation comments
3. Constants
4. Exported variables
5. Public variables
6. Private variables
7. Lifecycle methods (_ready, _process, _input)
8. Public methods
9. Private methods (prefixed with _)

## Dependencies

Scripts are organized to minimize dependencies:
- Data models have no dependencies
- Core systems depend only on data models
- Feedback systems depend on core systems
- Practice mode depends on everything

## Testing

Tests for these scripts are located in the `tests/` directory. See `tests/README.md` for details.
