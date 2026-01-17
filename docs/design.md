# Design Document: Practice Mode MVP

## Overview

Practice Mode MVP implements Zout's core striking mechanic in Godot 4 using GDScript. The design prioritizes feel over features through a physics-driven approach where Contact Quality directly influences ball behavior. The architecture separates input handling, strike calculation, physics simulation, and feedback systems to enable independent tuning of each layer.

The system uses a state machine for strike phases (Aiming → Charging → Contact → Flight → Outcome), with each state managing its own input, physics, and feedback. All visual and audio feedback is triggered by game state changes, never by arbitrary timers, ensuring tight coupling between player action and system response.

## Architecture

### High-Level Structure

```plaintext
PracticeMode (Scene Root)
├── StrikeController (Core Logic)
│   ├── AimSystem
│   ├── PowerSystem
│   ├── TimingSystem
│   └── ContactQualityCalculator
├── BallPhysics (RigidBody3D)
├── GoalDetector (Area3D)
├── FeedbackManager
│   ├── AudioFeedback
│   ├── CameraFeedback
│   └── UIFeedback
├── AssistSystem (Optional Guides)
└── StatsTracker
```

### State Machine

The strike flow follows a linear state progression:

1. **READY** - Ball at strike point, awaiting input
2. **AIMING** - Player adjusting aim direction
3. **CHARGING** - Power accumulating (hold input)
4. **CONTACT** - Timing window evaluation (release input)
5. **FLIGHT** - Ball in motion, physics active
6. **OUTCOME** - Goal detection and feedback
7. **RESET** - Return to READY state

State transitions are explicit and unidirectional (except RESET which returns to READY from any state).

## Components and Interfaces

### StrikeController

Central coordinator managing strike state and orchestrating subsystems.

**Properties:**

- `current_state: StrikeState` - Current phase of strike
- `strike_origin: Vector3` - Ball starting position
- `aim_direction: Vector3` - Current aim vector
- `power_level: float` - Charged power (0.0 to 1.0)
- `contact_quality: ContactQuality` - Calculated execution quality

**Methods:**

- `_ready()` - Initialize subsystems and set READY state
- `_process(delta)` - Update current state logic
- `_input(event)` - Route input to appropriate subsystem
- `execute_strike()` - Calculate and apply strike to ball
- `reset_strike()` - Return to READY state

**Signals:**

- `strike_executed(power, direction, quality)`
- `state_changed(old_state, new_state)`

### AimSystem

Handles aim input and direction calculation.

**Properties:**

- `aim_sensitivity: float` - Mouse/keyboard sensitivity
- `aim_cone_angle: float` - Maximum aim deviation from center
- `current_aim: Vector2` - Normalized aim input (-1 to 1 for X/Y)

**Methods:**

- `update_aim(input_vector: Vector2)` - Process aim input
- `get_aim_direction() -> Vector3` - Convert 2D input to 3D world direction
- `get_aim_cone_vertices() -> Array[Vector3]` - For assist visualization

**Configuration:**

- Keyboard: Arrow keys or WASD for discrete aim
- Mouse: Relative motion for continuous aim
- Aim cone: 45° horizontal, 30° vertical from goal center

### PowerSystem

Manages power charge timing and level calculation.

**Properties:**

- `charge_duration: float` - Time to reach 100% power (default: 1.5s)
- `charge_start_time: float` - Timestamp when charging began
- `is_charging: bool` - Current charge state

**Methods:**

- `start_charge()` - Begin power accumulation
- `get_current_power() -> float` - Calculate power based on elapsed time
- `release_charge() -> float` - Finalize and return power level

**Power Curve:**

- Linear accumulation from 0% to 100%
- No decay or penalty for holding at 100%
- Minimum viable power: 20% (below this, strike is rejected)

### TimingSystem

Evaluates contact timing and determines quality.

**Properties:**

- `perfect_window: float` - Perfect timing window in seconds (default: 0.05s)
- `clean_window: float` - Clean timing window (default: 0.15s)
- `okay_window: float` - Okay timing window (default: 0.30s)
- `optimal_timing: float` - Target timing point in charge cycle

**Methods:**

- `evaluate_timing(release_time: float) -> ContactQuality` - Determine quality from timing
- `get_timing_offset(release_time: float) -> float` - Calculate offset from optimal

**Timing Windows:**

- **Perfect**: ±0.05s from optimal (90-100% power range)
- **Clean**: ±0.15s from optimal (70-90% or 100% held)
- **Okay**: ±0.30s from optimal (40-70% range)
- **Scuffed**: Outside okay window or below 40% power

### ContactQualityCalculator

Combines timing and power to determine final Contact Quality.

**Methods:**

- `calculate_quality(power: float, timing_offset: float) -> ContactQuality` - Main calculation
- `get_quality_multiplier(quality: ContactQuality) -> float` - Scoring multiplier

**Quality Enum:**

```gdscript
enum ContactQuality {
    PERFECT,  # 1.25x multiplier
    CLEAN,    # 1.0x multiplier
    OKAY,     # 0.85x multiplier
    SCUFFED   # 0.7x multiplier
}
```

### BallPhysics

RigidBody3D with custom physics properties influenced by Contact Quality.

**Properties:**

- `base_speed: float` - Maximum ball velocity (default: 30 m/s)
- `mass: float` - Ball mass (default: 0.43 kg, regulation)
- `drag_coefficient: float` - Air resistance
- `drift_factor: float` - Applied based on Contact Quality

**Methods:**

- `apply_strike(direction: Vector3, power: float, quality: ContactQuality)` - Execute strike
- `apply_quality_effects(quality: ContactQuality)` - Modify physics properties
- `reset_position(position: Vector3)` - Return to strike point

**Quality Effects:**

- **Perfect**: No drift, max speed efficiency, tight trajectory
- **Clean**: Minimal drift (2° max deviation), 95% speed efficiency
- **Okay**: Moderate drift (5° max deviation), 85% speed efficiency
- **Scuffed**: High drift (10° max deviation), 70% speed efficiency, added spin

### GoalDetector

Area3D monitoring goal line crossings and zone detection.

**Properties:**

- `goal_area: Area3D` - Main goal detection volume
- `top_bins_left: Area3D` - Left top corner zone
- `top_bins_right: Area3D` - Right top corner zone
- `goal_width: float` - Standard goal width (7.32m)
- `goal_height: float` - Standard goal height (2.44m)

**Methods:**

- `_on_ball_entered(body: Node3D)` - Detect goal line crossing
- `check_top_bins(entry_position: Vector3) -> bool` - Determine if Top Bins
- `get_entry_point() -> Vector3` - Calculate exact crossing position

**Zone Definitions:**

- Top Bins: Upper 25% of height (1.83m - 2.44m) AND outer 30% of width (0-2.2m or 5.12m-7.32m)
- Goal detection triggers on ball center crossing goal plane

### FeedbackManager

Coordinates all audio, visual, and UI feedback.

**Methods:**

- `trigger_zout(is_top_bins: bool, quality: ContactQuality)` - Goal feedback
- `trigger_miss()` - Miss feedback
- `update_power_ui(power: float)` - Power bar display
- `show_score(points: int)` - Score popup

**Feedback Timing:**

- Strike impact: Immediate (0 frames delay)
- Zout call: On goal line crossing
- Score display: 0.3s after Zout
- Reset: 2.0s after outcome

### AudioFeedback

Manages all audio cues with layering and variation.

**Audio Assets:**

- `strike_perfect.wav` - Perfect contact sound
- `strike_clean.wav` - Clean contact sound
- `strike_okay.wav` - Okay contact sound
- `strike_scuffed.wav` - Scuffed contact sound
- `net_impact.wav` - Ball hitting net
- `zout_call.wav` - Zout voice line
- `top_bins_call.wav` - Top Bins voice line

**Methods:**

- `play_strike_audio(quality: ContactQuality)` - Layered strike sound
- `play_net_audio()` - Net impact
- `play_zout_audio(is_top_bins: bool)` - Outcome audio

**Audio Rules:**

- Never play same voice line twice consecutively
- Strike audio plays at contact frame
- Net audio plays on first net collision
- Zout audio plays 0.1s after goal detection

### CameraFeedback

Camera3D with dynamic behavior responding to strike phases.

**Properties:**

- `default_position: Vector3` - Behind ball, elevated view
- `default_fov: float` - Field of view (default: 75°)
- `shake_intensity: float` - Impact shake magnitude
- `slowmo_factor: float` - Time scale for Zout moments (default: 0.7)
- `push_in_distance: float` - Camera movement during charge (default: 0.5m)

**Methods:**

- `apply_charge_push()` - Subtle camera push-in during power charge
- `apply_impact_shake()` - Micro shake on ball contact
- `apply_zout_hold(is_top_bins: bool)` - Brief hold with slowmo
- `reset_to_default()` - Return to default position

**Camera Behavior:**

- Charge: Smooth push-in over charge duration
- Impact: Single frame shake (0.1m displacement)
- Zout: 0.3s hold with 0.7x time scale
- Top Bins: Additional 0.1s hold with slight corner emphasis

### UIFeedback

Manages on-screen UI elements and score display.

**Properties:**

- `power_bar: ProgressBar` - Visual power indicator
- `score_label: Label` - Score popup display
- `stats_panel: Panel` - Session statistics overlay

**Methods:**

- `update_power_bar(power: float)` - Update power visualization
- `show_score_popup(points: int)` - Display score briefly
- `show_stats(stats: Dictionary)` - Display session statistics
- `hide_all_ui()` - Clear all UI elements

**UI Timing:**

- Power bar: Updates every frame during charge
- Score popup: Appears 0.3s after Zout, fades after 1.5s
- Stats panel: Toggleable, semi-transparent overlay

### AssistSystem

Optional visual guides for learning the mechanics.

**Properties:**

- `aim_assist_enabled: bool` - Show aim cone
- `shot_preview_enabled: bool` - Show trajectory arc
- `aim_cone_mesh: MeshInstance3D` - Visual aim indicator
- `trajectory_line: Line3D` - Predicted ball path

**Methods:**

- `toggle_aim_assist(enabled: bool)` - Enable/disable aim cone
- `toggle_shot_preview(enabled: bool)` - Enable/disable trajectory
- `update_aim_cone(direction: Vector3)` - Update cone visualization
- `update_trajectory(power: float, direction: Vector3)` - Update arc prediction

**Assist Visuals:**

- Aim cone: Semi-transparent, updates in real-time
- Trajectory arc: Dotted line, accounts for current power
- Both disabled by default for experienced players

### StatsTracker

Tracks session statistics and achievements.

**Properties:**

- `total_attempts: int` - Total strikes taken
- `total_goals: int` - Total successful goals
- `top_bins_count: int` - Total Top Bins goals
- `current_streak: int` - Current consecutive goals
- `best_streak: int` - Best streak this session
- `total_score: int` - Accumulated score

**Methods:**

- `record_attempt()` - Increment attempt counter
- `record_goal(is_top_bins: bool, points: int)` - Record successful goal
- `record_miss()` - Record miss and reset streak
- `get_stats() -> Dictionary` - Return all statistics
- `reset_session()` - Clear all stats

**Stat Calculations:**

- Accuracy: `total_goals / total_attempts * 100`
- Top Bins Rate: `top_bins_count / total_goals * 100`

## Data Models

### StrikeData

Encapsulates all parameters of a single strike.

```gdscript
class_name StrikeData

var aim_direction: Vector3
var power_level: float
var timing_offset: float
var contact_quality: ContactQuality
var timestamp: float

func _init(direction: Vector3, power: float, timing: float, quality: ContactQuality):
    aim_direction = direction
    power_level = power
    timing_offset = timing
    contact_quality = quality
    timestamp = Time.get_ticks_msec() / 1000.0
```

### OutcomeData

Encapsulates the result of a strike.

```gdscript
class_name OutcomeData

var is_goal: bool
var is_top_bins: bool
var entry_position: Vector3
var points_awarded: int
var strike_data: StrikeData

func _init(goal: bool, top_bins: bool, position: Vector3, points: int, strike: StrikeData):
    is_goal = goal
    is_top_bins = top_bins
    entry_position = position
    points_awarded = points
    strike_data = strike
```

### SessionStats

Complete session statistics.

```gdscript
class_name SessionStats

var total_attempts: int = 0
var total_goals: int = 0
var top_bins_count: int = 0
var current_streak: int = 0
var best_streak: int = 0
var total_score: int = 0

func get_accuracy() -> float:
    return (float(total_goals) / float(total_attempts)) * 100.0 if total_attempts > 0 else 0.0

func get_top_bins_rate() -> float:
    return (float(top_bins_count) / float(total_goals)) * 100.0 if total_goals > 0 else 0.0
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Strike execution preserves input parameters

*For any* valid aim direction and power level (20%-100%), executing a strike should apply those exact parameters to the ball physics without modification.

**Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**

### Property 2: Contact quality determines ball behavior consistently

*For any* strike with a given contact quality, the ball's drift and speed efficiency should match the defined quality effects (Perfect: 0° drift, Clean: ≤2°, Okay: ≤5°, Scuffed: ≤10°).

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

### Property 3: Goal detection triggers only on goal line crossing

*For any* ball trajectory, Zout should trigger if and only if the ball center crosses the goal plane within the goal boundaries.

**Validates: Requirements 3.1, 3.2**

### Property 4: Top Bins detection requires both height and width criteria

*For any* goal, Top Bins should trigger if and only if the entry position is in the upper 25% of height AND outer 30% of width.

**Validates: Requirements 4.1, 4.5**

### Property 5: Scoring calculation follows defined formula

*For any* goal with known contact quality and Top Bins status, the calculated score should equal: (100 + (50 if Top Bins)) × quality_multiplier.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4**

### Property 6: Reset returns to initial state

*For any* game state (during aiming, charging, flight, or outcome), triggering reset should return the ball to strike origin and set state to READY within 2 seconds.

**Validates: Requirements 6.2, 6.3**

### Property 7: Assist system does not affect physics

*For any* strike with assists enabled vs disabled, given identical input parameters, the ball trajectory and scoring should be identical.

**Validates: Requirements 7.5**

### Property 8: Statistics accumulate correctly

*For any* sequence of strikes, the total goals should equal the count of strikes where Zout was triggered, and total attempts should equal the count of all strikes executed.

**Validates: Requirements 8.1, 8.2, 8.3, 8.4**

### Property 9: Audio feedback matches outcome

*For any* strike outcome, if Zout is triggered, the Zout audio should play; if Top Bins is triggered, the Top Bins audio should play; both should never play for a miss.

**Validates: Requirements 10.3, 10.4**

### Property 10: Input responsiveness meets timing requirements

*For any* player input (aim, power, reset), the system should respond within the specified frame/time limits (aim: 1 frame, power: immediate, reset: 0.5s).

**Validates: Requirements 12.1, 12.2, 12.3, 12.4**

## Error Handling

### Input Validation

**Invalid Power Levels:**

- Power below 20% threshold: Reject strike, display "Too weak" message, return to READY state
- Power above 100%: Clamp to 100%, proceed normally

**Invalid Aim Direction:**

- Aim outside cone bounds: Clamp to nearest valid direction
- Zero vector aim: Default to goal center

**Rapid Input Spam:**

- Ignore input during FLIGHT and OUTCOME states
- Queue reset requests, execute after current outcome completes

### Physics Edge Cases

**Ball Stuck or Out of Bounds:**

- If ball velocity < 0.1 m/s for 3 seconds: Auto-reset
- If ball position exceeds 50m from origin: Auto-reset

**Goal Detection Ambiguity:**

- Ball touching goal line but not fully crossed: No goal
- Ball crosses line then bounces back: Goal still counts (first crossing wins)

**Multiple Collision Events:**

- Net collision during goal detection: Prioritize goal detection, play net audio after Zout

### Audio System Failures

**Missing Audio Files:**

- Log warning, continue without audio
- Use fallback silent audio to prevent crashes

**Consecutive Voice Line Prevention:**

- Track last played voice line
- If same line requested, skip audio but continue visual feedback

### Camera System Failures

**Invalid Camera Position:**

- If camera position becomes NaN or exceeds bounds: Reset to default position
- Log error for debugging

**Slowmo Time Scale Issues:**

- If time scale doesn't restore after Zout: Force reset to 1.0 after 2 seconds

### Statistics Overflow

**Integer Overflow Protection:**

- Cap all counters at 999,999
- Display "999,999+" in UI if cap reached

## Testing Strategy

### Unit Testing

Unit tests verify specific examples, edge cases, and error conditions using Godot's GUT (Godot Unit Test) framework.

**Test Coverage:**

- ContactQualityCalculator: Test all timing windows and boundary conditions
- GoalDetector: Test goal line crossing detection and Top Bins zones
- StatsTracker: Test stat accumulation and accuracy calculations
- PowerSystem: Test charge timing and power level calculation
- AimSystem: Test input conversion and cone clamping

**Example Unit Tests:**

- Test perfect timing at exactly 90% power
- Test goal detection at exact goal line boundary
- Test Top Bins detection at zone boundaries
- Test score calculation with all quality levels
- Test reset from each state

### Property-Based Testing

Property tests verify universal properties across all inputs using GDScript property testing (custom implementation or gdUnit4).

**Configuration:**

- Minimum 100 iterations per property test
- Random seed logged for reproducibility
- Each test references design document property number

**Test Implementation:**

- **Property 1**: Generate random aim/power, verify ball receives exact values
- **Property 2**: Generate random quality levels, measure actual drift angles
- **Property 3**: Generate random trajectories, verify Zout triggers only on crossing
- **Property 4**: Generate random entry positions, verify Top Bins logic
- **Property 5**: Generate random outcomes, verify score formula
- **Property 6**: Generate random states, verify reset behavior
- **Property 7**: Generate random strikes with/without assists, verify identical physics
- **Property 8**: Generate random strike sequences, verify stat accumulation
- **Property 9**: Generate random outcomes, verify audio matching
- **Property 10**: Measure input response times, verify within limits

**Property Test Tags:**

```gdscript
# Feature: practice-mode-mvp, Property 1: Strike execution preserves input parameters
func test_property_strike_execution_preserves_parameters():
    # Test implementation
```

### Integration Testing

**Full Strike Flow:**

- Test complete flow from READY → AIMING → CHARGING → CONTACT → FLIGHT → OUTCOME → RESET
- Verify all subsystems coordinate correctly
- Test with various input combinations

**Feedback Coordination:**

- Test audio, camera, and UI feedback trigger together
- Verify timing relationships between feedback elements
- Test Zout + Top Bins combined feedback

### Manual Testing Focus

**Feel and Polish:**

- Strike impact feel (requires human judgment)
- Camera movement smoothness
- Audio layering quality
- UI readability and timing
- Overall "Zout" experience

**Performance:**

- Frame rate stability during strikes
- Physics simulation consistency
- Memory usage over extended sessions
