# Implementation Plan: Practice Mode MVP

## Overview

This plan implements Zout's Practice Mode in Godot 4 using GDScript. The approach follows a bottom-up strategy: core systems first (strike mechanics, physics, detection), then feedback layers (audio, camera, UI), and finally the practice mode wrapper. Each task builds incrementally, with frequent checkpoints to validate feel and functionality.

## Tasks

- [x] 1. Project setup and scene foundation
  - Create Godot 4 project with GDScript
  - Set up basic scene structure: pitch plane, goal mesh, ball RigidBody3D
  - Configure camera with default position behind ball
  - Implement quick reset (R key) to restart scene
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 1.1 Write unit tests for scene initialization

  - Test scene loads within 3 seconds
  - Test all required nodes exist in scene tree
  - _Requirements: 11.5_

- [x] 2. Implement core data models
  - Create StrikeData class with aim, power, timing, quality fields
  - Create OutcomeData class with goal status, Top Bins, points, entry position
  - Create SessionStats class with stat tracking and calculation methods
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 4.1, 5.1, 8.1, 8.2, 8.3, 8.4_

- [x] 2.1 Write property test for data model integrity

  - **Property 1: Strike execution preserves input parameters**
  - **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**
  - Generate random aim/power values, verify StrikeData stores them exactly

- [x] 3. Implement ContactQualityCalculator
  - Create ContactQuality enum (PERFECT, CLEAN, OKAY, SCUFFED)
  - Implement calculate_quality() method using timing windows
  - Implement get_quality_multiplier() for scoring
  - Define timing windows: Perfect ±0.05s, Clean ±0.15s, Okay ±0.30s
  - _Requirements: 1.4, 2.1, 2.2, 2.3, 2.4, 5.3_

- [ ]* 3.1 Write unit tests for timing windows
  - Test boundary conditions for each quality level
  - Test edge cases (0% power, 100% power, exact optimal timing)
  - _Requirements: 1.4, 2.1, 2.2, 2.3, 2.4_

- [ ]* 3.2 Write property test for contact quality consistency
  - **Property 2: Contact quality determines ball behavior consistently**
  - **Validates: Requirements 2.1, 2.2, 2.3, 2.4**
  - Generate random timing offsets, verify quality assignment matches windows

- [x] 4. Implement AimSystem
  - Create AimSystem class with aim_sensitivity and aim_cone_angle properties
  - Implement update_aim() for keyboard (WASD/arrows) and mouse input
  - Implement get_aim_direction() to convert 2D input to 3D world direction
  - Clamp aim within cone bounds (45° horizontal, 30° vertical)
  - Implement get_aim_cone_vertices() for assist visualization
  - _Requirements: 1.1, 12.1_

- [ ]* 4.1 Write unit tests for aim clamping
  - Test aim stays within cone bounds
  - Test extreme input values
  - Test zero vector defaults to goal center
  - _Requirements: 1.1_

- [x] 5. Implement PowerSystem
  - Create PowerSystem class with charge_duration (1.5s default)
  - Implement start_charge() to begin power accumulation
  - Implement get_current_power() with linear 0-100% curve
  - Implement release_charge() to finalize power level
  - Reject strikes below 20% power threshold
  - _Requirements: 1.2, 12.2_

- [ ]* 5.1 Write unit tests for power charging
  - Test power reaches 100% at charge_duration
  - Test power rejection below 20%
  - Test power clamps at 100% when held
  - _Requirements: 1.2_

- [x] 6. Implement TimingSystem
  - Create TimingSystem class with timing window properties
  - Implement evaluate_timing() to determine ContactQuality from release time
  - Implement get_timing_offset() to calculate offset from optimal
  - Configure optimal timing at 90-100% power range
  - _Requirements: 1.3, 1.4_

- [ ]* 6.1 Write unit tests for timing evaluation
  - Test each timing window produces correct quality
  - Test optimal timing point
  - _Requirements: 1.3, 1.4_

- [x] 7. Checkpoint - Core systems validation
  - Ensure all core system tests pass
  - Verify data models, quality calculator, aim, power, and timing systems work independently
  - Ask user if questions arise

- [x] 8. Implement BallPhysics
  - Create BallPhysics script extending RigidBody3D
  - Set ball mass to 0.43 kg, configure drag coefficient
  - Implement apply_strike() to apply direction, power, and quality to ball
  - Implement apply_quality_effects() to modify drift based on quality
  - Implement reset_position() to return ball to strike origin
  - Quality effects: Perfect (0° drift), Clean (≤2°), Okay (≤5°), Scuffed (≤10°)
  - _Requirements: 1.5, 2.1, 2.2, 2.3, 2.4, 11.3_

- [ ]* 8.1 Write property test for quality effects on physics
  - **Property 2: Contact quality determines ball behavior consistently**
  - **Validates: Requirements 2.1, 2.2, 2.3, 2.4**
  - Generate random strikes with each quality, measure actual drift angles

- [ ]* 8.2 Write unit tests for ball physics edge cases
  - Test ball stuck detection (velocity < 0.1 m/s for 3s)
  - Test out of bounds detection (>50m from origin)
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 9. Implement GoalDetector
  - Create GoalDetector script with Area3D for goal detection
  - Set goal dimensions: 7.32m width, 2.44m height
  - Implement _on_ball_entered() to detect goal line crossing
  - Implement check_top_bins() for top corner detection
  - Define Top Bins zones: upper 25% height (1.83-2.44m) AND outer 30% width
  - Implement get_entry_point() to calculate exact crossing position
  - _Requirements: 3.1, 3.2, 4.1, 4.5_

- [ ]* 9.1 Write property test for goal detection
  - **Property 3: Goal detection triggers only on goal line crossing**
  - **Validates: Requirements 3.1, 3.2**
  - Generate random ball trajectories, verify Zout triggers only when crossing goal plane

- [ ]* 9.2 Write property test for Top Bins detection
  - **Property 4: Top Bins detection requires both height and width criteria**
  - **Validates: Requirements 4.1, 4.5**
  - Generate random entry positions, verify Top Bins logic (upper 25% AND outer 30%)

- [ ]* 9.3 Write unit tests for goal detection edge cases
  - Test ball touching but not crossing goal line
  - Test ball crossing then bouncing back
  - Test Top Bins zone boundaries
  - _Requirements: 3.1, 3.2, 4.1, 4.5_

- [x] 10. Implement StrikeController state machine
  - Create StrikeController script with StrikeState enum
  - Implement state machine: READY → AIMING → CHARGING → CONTACT → FLIGHT → OUTCOME → RESET
  - Implement _ready() to initialize subsystems
  - Implement _process(delta) to update current state logic
  - Implement _input(event) to route input to subsystems
  - Implement execute_strike() to calculate and apply strike
  - Implement reset_strike() to return to READY state
  - Define signals: strike_executed, state_changed
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 6.1, 6.2, 6.3, 12.1, 12.2, 12.3, 12.4_

- [ ]* 10.1 Write unit tests for state transitions
  - Test each state transition occurs correctly
  - Test reset from each state returns to READY
  - Test invalid state transitions are rejected
  - _Requirements: 6.1, 6.2, 6.3_

- [ ]* 10.2 Write property test for reset behavior
  - **Property 6: Reset returns to initial state**
  - **Validates: Requirements 6.2, 6.3**
  - Generate random game states, verify reset returns to READY within 2s

- [ ]* 10.3 Write property test for input responsiveness
  - **Property 10: Input responsiveness meets timing requirements**
  - **Validates: Requirements 12.1, 12.2, 12.3, 12.4**
  - Measure input response times, verify within limits (aim: 1 frame, power: immediate, reset: 0.5s)

- [x] 11. Checkpoint - Core mechanics validation
  - Test complete strike flow: aim → charge → contact → flight → outcome
  - Verify ball physics responds to contact quality
  - Verify goal detection works correctly
  - Ask user if the strike "feel" is right

- [x] 12. Implement AudioFeedback system
  - Create AudioFeedback script with AudioStreamPlayer nodes
  - Prepare audio asset placeholders: strike sounds (4 qualities), net impact, Zout call, Top Bins call
  - Implement play_strike_audio() with quality-based layering
  - Implement play_net_audio() for net collision
  - Implement play_zout_audio() for goal confirmation
  - Implement consecutive voice line prevention
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ]* 12.1 Write property test for audio feedback matching
  - **Property 9: Audio feedback matches outcome**
  - **Validates: Requirements 10.3, 10.4**
  - Generate random outcomes, verify correct audio plays (Zout for goals, Top Bins for corners, none for misses)

- [ ]* 12.2 Write unit tests for audio edge cases
  - Test consecutive voice line prevention
  - Test missing audio file handling
  - _Requirements: 10.5_

- [x] 13. Implement CameraFeedback system
  - Create CameraFeedback script extending Camera3D
  - Set default position behind ball with 75° FOV
  - Implement apply_charge_push() for subtle push-in during charge
  - Implement apply_impact_shake() for micro shake on contact
  - Implement apply_zout_hold() for brief slowmo (0.7x time scale)
  - Implement reset_to_default() to return camera to default position
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ]* 13.1 Write unit tests for camera behavior
  - Test camera position changes during each phase
  - Test camera reset to default
  - Test slowmo time scale restoration
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 14. Implement scoring system
  - Integrate scoring into StrikeController
  - Implement score calculation: base 100 points for Zout, +50 for Top Bins
  - Apply ContactQuality multiplier: Perfect 1.25x, Clean 1.0x, Okay 0.85x, Scuffed 0.7x
  - Accumulate total score across session
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ]* 14.1 Write property test for scoring calculation
  - **Property 5: Scoring calculation follows defined formula**
  - **Validates: Requirements 5.1, 5.2, 5.3, 5.4**
  - Generate random outcomes with all quality/Top Bins combinations, verify score formula

- [ ]* 14.2 Write unit tests for scoring edge cases
  - Test score calculation for each quality level
  - Test Top Bins bonus application
  - Test score accumulation
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 15. Implement UIFeedback system
  - Create UIFeedback script with Control nodes
  - Create power bar ProgressBar that updates during charge
  - Create score label that displays points briefly after Zout
  - Implement update_power_bar() to show current power
  - Implement show_score_popup() with 0.3s delay after Zout, 1.5s fade
  - Implement hide_all_ui() for clean Zout moments
  - _Requirements: 5.4, 9.4_

- [ ]* 15.1 Write unit tests for UI timing
  - Test power bar updates every frame during charge
  - Test score popup timing (0.3s delay, 1.5s fade)
  - _Requirements: 5.4_

- [x] 16. Implement FeedbackManager coordinator
  - Create FeedbackManager script to orchestrate all feedback
  - Implement trigger_zout() to coordinate audio, camera, UI for goals
  - Implement trigger_miss() for miss feedback
  - Ensure feedback timing: strike audio immediate, Zout audio 0.1s after detection, score 0.3s after Zout
  - Connect to StrikeController signals
  - _Requirements: 3.3, 3.4, 4.2, 4.3, 4.4, 5.4_

- [x] 16.1 Write integration tests for feedback coordination

  - Test all feedback systems trigger together for Zout
  - Test Top Bins stacks on Zout correctly
  - Test feedback timing relationships
  - _Requirements: 3.3, 3.4, 4.2, 4.3, 4.4_

- [x] 17. Checkpoint - Feedback systems validation
  - Test complete strike with all feedback (audio, camera, UI)
  - Verify Zout moment feels earned and restrained
  - Verify Top Bins feels distinct from regular goals
  - Ask user if the feedback "feel" matches Zout's tone

- [x] 18. Implement StatsTracker
  - Create StatsTracker script with session stat properties
  - Implement record_attempt() to increment attempt counter
  - Implement record_goal() to track goals, Top Bins, streaks, score
  - Implement record_miss() to reset current streak
  - Implement get_stats() to return all statistics
  - Implement reset_session() to clear stats
  - Calculate accuracy and Top Bins rate
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ]* 18.1 Write property test for statistics accumulation
  - **Property 8: Statistics accumulate correctly**
  - **Validates: Requirements 8.1, 8.2, 8.3, 8.4**
  - Generate random strike sequences, verify stat counts match outcomes

- [ ]* 18.2 Write unit tests for stat calculations
  - Test accuracy calculation
  - Test Top Bins rate calculation
  - Test streak tracking (current and best)
  - Test integer overflow protection (cap at 999,999)
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 19. Implement AssistSystem
  - Create AssistSystem script with toggle properties
  - Create aim cone MeshInstance3D for visual aim indicator
  - Create trajectory Line3D for shot preview
  - Implement toggle_aim_assist() to show/hide aim cone
  - Implement toggle_shot_preview() to show/hide trajectory
  - Implement update_aim_cone() to update cone in real-time
  - Implement update_trajectory() to predict ball path based on power/aim
  - Both assists disabled by default
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ]* 19.1 Write property test for assist system independence
  - **Property 7: Assist system does not affect physics**
  - **Validates: Requirements 7.5**
  - Generate random strikes with assists on/off, verify identical ball trajectory and scoring

- [ ]* 19.2 Write unit tests for assist toggles
  - Test assists can be toggled during gameplay
  - Test assists don't affect scoring
  - _Requirements: 7.3, 7.4, 7.5_

- [x] 20. Implement Practice Mode loop
  - Create PracticeMode scene as root with all subsystems
  - Implement infinite attempt loop: strike → outcome → reset → repeat
  - Implement auto-reset 2 seconds after outcome
  - Implement manual reset (R key) from any state
  - Ensure session continuity until player exits
  - Wire all systems together: StrikeController, BallPhysics, GoalDetector, FeedbackManager, StatsTracker, AssistSystem
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ]* 20.1 Write integration tests for practice mode loop
  - Test infinite attempt loop works correctly
  - Test auto-reset timing (2s after outcome)
  - Test manual reset from each state
  - _Requirements: 6.2, 6.3, 6.4, 6.5_

- [x] 21. Implement stats display UI
  - Create stats panel overlay (semi-transparent)
  - Display: total attempts, total goals, Top Bins count, current streak, best streak, total score, accuracy %, Top Bins rate %
  - Implement toggle (Tab key) to show/hide stats
  - Stats panel non-intrusive, doesn't block gameplay
  - _Requirements: 8.5_

- [ ]* 21.1 Write unit tests for stats display
  - Test stats panel displays correct values
  - Test stats panel toggle
  - _Requirements: 8.5_

- [x] 22. Checkpoint - Practice Mode complete loop
  - Test full practice session: multiple strikes, stat tracking, assists, reset
  - Verify all systems work together seamlessly
  - Verify practice mode feels like "training" (calm, focused, repeatable)
  - Ask user if practice mode achieves the MVP goal

- [x] 23. Implement error handling and edge cases
  - Add input validation: reject power <20%, clamp aim to cone
  - Add physics edge case handling: auto-reset if ball stuck or out of bounds
  - Add audio fallback for missing files
  - Add camera position validation and reset
  - Add slowmo time scale restoration failsafe
  - Add statistics overflow protection (cap at 999,999)
  - _Requirements: All_

- [ ]* 23.1 Write unit tests for error handling
  - Test invalid power rejection
  - Test aim clamping
  - Test ball stuck auto-reset
  - Test missing audio file handling
  - Test stat overflow protection
  - _Requirements: All_

- [x] 24. Polish pass - feel and juice
  - Tune strike sound layering for each quality level
  - Tune net sound to be distinct from crossbar/post
  - Tune camera shake intensity (subtle, not distracting)
  - Tune slowmo factor for Zout moments (0.7x feels right?)
  - Tune Top Bins camera emphasis (slight corner framing)
  - Tune power bar visual design (clean, minimal)
  - Tune score popup timing and fade
  - Ensure no long pauses or forced celebrations
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4_

- [x] 25. Create basic main menu
  - Create MainMenu scene with simple UI
  - Add "Practice" button to load Practice Mode
  - Add "Settings" button (placeholder for now)
  - Add "Quit" button
  - Use Zout tone: minimal text, no subtitles
  - _Requirements: None (MVP wrapper)_

- [x] 26. Implement basic settings
  - Create Settings scene with toggle options
  - Add sound on/off toggle
  - Add aim assist toggle
  - Add shot preview toggle
  - Settings persist between sessions (save to user://settings.cfg)
  - _Requirements: 7.3, 7.4_

- [x] 27. Final checkpoint - MVP complete
  - Test complete flow: main menu → practice mode → multiple sessions → settings → quit
  - Verify all requirements are met
  - Verify all tests pass
  - Verify the game feels like "Zout" (calm, confident, focused)
  - Ask user if MVP is ready to ship

- [x] 28. Build and package
  - Create desktop build (Windows/Mac/Linux)
  - Test build on target platform
  - Verify performance (60 FPS minimum)
  - Create one short gameplay clip for sharing
  - _Requirements: 11.5_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation of feel and functionality
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Focus on "feel" over features - if it doesn't feel right, iterate before moving forward
