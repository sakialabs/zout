# Changelog

All notable changes to Zout will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] - 2026-01-16 - MVP RELEASE 🚀

### Added
- Complete strike mechanics (aim, power, timing with 4 quality levels)
- Ball physics with quality-based drift and speed
- Goal detection with Zout confirmation and Top Bins recognition
- Scoring system with quality multipliers (Perfect 1.25x, Clean 1.0x, Okay 0.85x, Scuffed 0.7x)
- Infinite practice loop with auto-reset (2s) and manual reset (R key)
- Optional assist system (aim cone, trajectory preview)
- Session statistics tracking (attempts, goals, streaks, accuracy)
- Main menu with practice/settings/quit navigation
- Settings system with persistent preferences (sound, assists)
- Audio feedback with volume tuning and layering
- Camera feedback (push-in, shake, slowmo at 0.7x)
- UI feedback (power bar, score popup, stats panel)
- Build automation script for Windows/Linux/macOS

### Changed
- Tuned camera effects for subtlety (shake 0.08, push 0.3m)
- Optimized feedback timing (score delay 0.25s, holds 0.25s/0.35s)
- Polished UI visuals (vibrant green power bar, minimal design)

### Technical
- All 28 mandatory tasks completed
- All 12 requirements validated (64/64 acceptance criteria)
- State machine with 7 phases
- Error handling and failsafes implemented
- Performance target: 60 FPS

---

## [Unreleased]

### Phase 1 - Core Strike Mechanic ✅ COMPLETE

#### Added

- **Aim System** - Keyboard/mouse input with 45° horizontal and 30° vertical cone bounds
- **Power Charge System** - Linear charge from 0-100% over 1.5 seconds, 20% minimum threshold
- **Contact Timing System** - Optimal timing window at 90-100% power range
- **Contact Quality Calculator** - Four quality levels (Perfect/Clean/Okay/Scuffed) based on timing
- **Ball Physics** - Quality-based drift and speed efficiency:
  - Perfect: 0° drift, 100% speed, 1.25x multiplier
  - Clean: ≤2° drift, 95% speed, 1.0x multiplier
  - Okay: ≤5° drift, 85% speed, 0.85x multiplier
  - Scuffed: ≤10° drift, 70% speed, 0.7x multiplier
- **Goal Detection** - Accurate goal line crossing detection with entry position calculation
- **Top Bins Detection** - Corner goal recognition (upper 25% height AND outer 30% width)
- **Strike Controller** - State machine managing complete strike flow
- **Data Models** - StrikeData, OutcomeData, SessionStats classes
- **Reset Functionality** - R key reset from any state, completes within 0.5s

#### Technical

- State machine: READY → AIMING → CHARGING → CONTACT → FLIGHT → OUTCOME → RESET
- Input responsiveness: <1 frame delay for aim, immediate power response
- Physics simulation with quality-based drift and spin
- Collision detection for goal boundaries and Top Bins zones

#### Testing

- Core systems validation suite (Task 7 checkpoint)
- Strike flow integration tests (Task 11 checkpoint)
- Manual testing procedures documented in `docs/testing.md`

---

### Phase 0 - Foundation ✅ COMPLETE

#### Added

- **Project Setup** - Godot 4.3 project initialization
- **Scene Structure** - Pitch, goal, ball (RigidBody3D), camera
- **Basic Physics** - Ball mass (0.43kg), gravity, drag coefficient
- **Input Configuration** - WASD/Arrows for aim, Space for power, R for reset
- **Quick Reset** - Scene reset functionality

#### Technical

- Goal dimensions: 7.32m × 2.44m (regulation size)
- Ball positioned at (0, 0.5, -20), goal at (0, 1.22, 40)
- Camera positioned behind ball with 75° FOV
- Scene loads within 3 seconds

---

### Phase 2 - Zout Logic ✅ COMPLETE

#### Added

- **Audio Feedback System** - Quality-based strike sounds, net impact, Zout/Top Bins voice lines
- **Camera Feedback System** - Charge push-in, impact shake, Zout slowmo (0.7x time scale)
- **UI Feedback System** - Power bar, score popup with timing (0.3s delay, 1.5s fade)
- **Feedback Manager** - Coordinated audio/camera/UI feedback with precise timing
- **Scoring System** - Base 100 points + 50 Top Bins bonus, quality multipliers applied
- **Stats Tracker** - Session tracking: attempts, goals, Top Bins, streaks, accuracy, score
- **Assist System** - Optional aim cone and trajectory preview (both disabled by default)

#### Technical

- Feedback timing: strike audio immediate, Zout audio 0.1s after detection, score 0.3s after Zout
- Camera effects: subtle push-in during charge, micro shake on impact, brief slowmo on Zout
- Stats overflow protection: all counters capped at 999,999
- Assist toggles: C key for aim cone, T key for trajectory preview
- Assists don't affect physics or scoring

#### Testing

- Feedback coordination integration tests (Task 16.1)
- Stats tracker unit tests (Task 18)
- Test organization restructured: unit/, property/, integration/, scenes/

---

## Development Status

**Current Phase:** Phase 3 - Practice Mode Loop  
**Last Checkpoint:** Task 19 - AssistSystem Implementation (Complete)  
**Next Milestone:** Task 20 - Practice Mode Loop

---

## Notes

- See `docs/roadmap.md` for full development plan
- See `docs/testing.md` for testing procedures
- See `tests/README.md` for test organization
- See `.kiro/specs/practice-mode-mvp/` for detailed requirements and design
