# Zout Testing Guide

This document contains all testing procedures for Zout features and mechanics.

---

## Table of Contents

- [Setup](#setup)
- [Core Strike Mechanic Tests](#core-strike-mechanic-tests)
- [Goal Detection Tests](#goal-detection-tests)
- [Top Bins Tests](#top-bins-tests)
- [Feel Assessment](#feel-assessment)

---

## Setup

### Running Tests

**Manual Testing (Recommended for Feel Validation):**
1. Open Godot 4.3 editor
2. Load the project
3. Open `scenes/practice_mode.tscn`
4. Press F5 to run the scene
5. Follow test procedures below

**Automated Core Systems Test:**
1. Open Godot 4.3 editor
2. Open `scenes/core_systems_validation.tscn`
3. Press F5 to run
4. Review console output for validation results

### Controls

- **WASD / Arrow Keys**: Aim
- **SPACE**: Hold to charge power, release to strike
- **R**: Reset

---

## Core Strike Mechanic Tests

### Test 1: Complete Strike Flow

**Objective:** Verify the complete strike flow works correctly (aim → charge → contact → flight → outcome)

**Steps:**
1. Press WASD or Arrow keys to aim
2. Hold SPACE to charge power
3. Release SPACE when power reaches desired level
4. Observe ball flight and outcome

**Expected Behavior:**
- ✓ Aim responds immediately to input (within 1 frame)
- ✓ Power charges smoothly from 0% to 100% over 1.5 seconds
- ✓ Ball launches immediately on release
- ✓ Ball travels toward aimed direction
- ✓ Goal detection triggers when ball crosses goal line
- ✓ Console shows state transitions: READY → AIMING → CHARGING → CONTACT → FLIGHT → OUTCOME

**Success Criteria:**
- All state transitions occur correctly
- No lag or delay in input response
- Ball launches with appropriate speed based on power level

---

### Test 2: Contact Quality Affects Ball Physics

#### Test 2a: Perfect Contact

**Objective:** Verify perfect contact produces minimal drift and maximum speed

**Steps:**
1. Aim at goal center (no aim input)
2. Hold SPACE for ~1.4 seconds (95% power)
3. Release at optimal timing
4. Observe ball trajectory

**Expected:**
- ✓ Console shows "Quality=PERFECT"
- ✓ Ball travels in straight line with minimal drift (< 0.5°)
- ✓ Ball reaches maximum speed
- ✓ No visible wobble or spin

#### Test 2b: Clean Contact

**Objective:** Verify clean contact produces slight drift and high speed

**Steps:**
1. Aim at goal center
2. Hold SPACE for ~1.2 seconds (80% power)
3. Release
4. Observe ball trajectory

**Expected:**
- ✓ Console shows "Quality=CLEAN"
- ✓ Ball has slight drift (≤ 2°)
- ✓ Ball speed is 95% of maximum
- ✓ Minimal wobble

#### Test 2c: Okay Contact

**Objective:** Verify okay contact produces noticeable drift and moderate speed

**Steps:**
1. Aim at goal center
2. Hold SPACE for ~0.9 seconds (60% power)
3. Release
4. Observe ball trajectory

**Expected:**
- ✓ Console shows "Quality=OKAY"
- ✓ Ball has noticeable drift (≤ 5°)
- ✓ Ball speed is 85% of maximum
- ✓ Some wobble visible

#### Test 2d: Scuffed Contact

**Objective:** Verify scuffed contact produces significant drift and low speed

**Steps:**
1. Aim at goal center
2. Hold SPACE for ~0.5 seconds (33% power)
3. Release
4. Observe ball trajectory

**Expected:**
- ✓ Console shows "Quality=SCUFFED"
- ✓ Ball has significant drift (≤ 10°)
- ✓ Ball speed is 70% of maximum
- ✓ Ball may have added spin
- ✓ Trajectory is unstable

**Success Criteria:**
- Contact quality visibly affects ball behavior
- Drift increases with lower quality
- Speed efficiency decreases with lower quality
- Player can feel the difference between qualities

---

### Test 3: Power Charge System

**Objective:** Verify power charges correctly over time

**Steps:**
1. Hold SPACE and observe power level in console
2. Release at various times (0.3s, 0.75s, 1.5s, 2.0s)
3. Observe ball speed for each power level

**Expected:**
- ✓ Power reaches 0% at start
- ✓ Power reaches ~50% at 0.75s
- ✓ Power reaches 100% at 1.5s
- ✓ Power stays at 100% when held longer
- ✓ Strikes below 20% power are rejected
- ✓ Ball speed scales with power level

**Success Criteria:**
- Power charge is smooth and linear
- 1.5s duration feels appropriate
- Low power strikes are properly rejected

---

### Test 4: Aim System

**Objective:** Verify aim responds correctly to input

**Steps:**
1. Press WASD keys in different combinations
2. Observe aim direction changes
3. Try extreme aim inputs (max left, max right, max up, max down)
4. Verify aim is clamped to cone bounds

**Expected:**
- ✓ Aim updates immediately (within 1 frame)
- ✓ Horizontal aim: ±45° from center
- ✓ Vertical aim: ±30° from center
- ✓ Aim is clamped at cone boundaries
- ✓ Zero input defaults to goal center

**Success Criteria:**
- Aim feels responsive
- Cone bounds are appropriate (not too wide or narrow)
- Clamping is smooth, not jarring

---

## Goal Detection Tests

### Test 5: Goal Center

**Objective:** Verify goal detection works for center shots

**Steps:**
1. Aim at goal center (no aim input)
2. Charge to 80%+ power
3. Release and observe

**Expected:**
- ✓ Console shows "⚽ GOAL!"
- ✓ Entry position is near goal center (X ≈ 0, Y ≈ 1.22)
- ✓ State transitions to OUTCOME
- ✓ Ball is detected crossing goal line (Z = 40)

### Test 6: Goal Miss (Outside Width)

**Objective:** Verify misses are detected when ball is outside goal width

**Steps:**
1. Aim far left or right (max horizontal aim)
2. Charge to 80%+ power
3. Release and observe

**Expected:**
- ✓ Console shows "❌ Miss!"
- ✓ No goal detected
- ✓ Ball passes outside goal boundaries (|X| > 3.66m)
- ✓ State transitions to OUTCOME

### Test 7: Goal Miss (Above Height)

**Objective:** Verify misses are detected when ball is above goal height

**Steps:**
1. Aim upward (max vertical aim)
2. Charge to 80%+ power
3. Release and observe

**Expected:**
- ✓ Console shows "❌ Miss!"
- ✓ Ball passes above goal (Y > 2.44m)
- ✓ No goal detected
- ✓ State transitions to OUTCOME

**Success Criteria:**
- Goal detection only triggers when ball crosses goal line within boundaries
- Entry position is accurately calculated
- Misses are correctly identified
- Boundaries are clear and consistent

---

## Top Bins Tests

### Test 8: Top Left Corner

**Objective:** Verify Top Bins detection in top left corner

**Steps:**
1. Aim left and up (aim input: -0.8, 0.8)
2. Charge to 90%+ power
3. Release and observe

**Expected:**
- ✓ Console shows "🎯 GOAL! TOP BINS!"
- ✓ Entry position is in top left corner zone
- ✓ Entry Y > 1.83m (upper 25% of 2.44m)
- ✓ Entry X < -2.2m (outer 30% of 7.32m width)

### Test 9: Top Right Corner

**Objective:** Verify Top Bins detection in top right corner

**Steps:**
1. Aim right and up (aim input: 0.8, 0.8)
2. Charge to 90%+ power
3. Release and observe

**Expected:**
- ✓ Console shows "🎯 GOAL! TOP BINS!"
- ✓ Entry position is in top right corner zone
- ✓ Entry Y > 1.83m
- ✓ Entry X > 2.2m

### Test 10: Top Center (Not Top Bins)

**Objective:** Verify Top Bins does NOT trigger for top center shots

**Steps:**
1. Aim up only (aim input: 0, 0.8)
2. Charge to 90%+ power
3. Release and observe

**Expected:**
- ✓ Console shows "⚽ GOAL!" (not Top Bins)
- ✓ Entry position is in top center
- ✓ Entry Y > 1.83m but |X| < 2.2m (not in outer 30%)

### Test 11: Bottom Corner (Not Top Bins)

**Objective:** Verify Top Bins does NOT trigger for bottom corners

**Steps:**
1. Aim left and slightly down (aim input: -0.8, -0.2)
2. Charge to 90%+ power
3. Release and observe

**Expected:**
- ✓ Console shows "⚽ GOAL!" (not Top Bins)
- ✓ Entry position is in bottom left
- ✓ Entry Y < 1.83m (not in upper 25%)

**Success Criteria:**
- Top Bins only triggers in top corners (upper 25% height AND outer 30% width)
- Top center and bottom corners do not trigger Top Bins
- Detection is consistent and accurate

---

## Reset Functionality Tests

### Test 12: Reset During Aiming

**Objective:** Verify reset works during aiming phase

**Steps:**
1. Press WASD to start aiming
2. Press R to reset
3. Observe

**Expected:**
- ✓ State returns to READY
- ✓ Ball returns to start position
- ✓ Aim input is cleared
- ✓ Reset completes within 0.5s

### Test 13: Reset During Charging

**Objective:** Verify reset works during power charge

**Steps:**
1. Hold SPACE to charge
2. Press R while charging
3. Observe

**Expected:**
- ✓ State returns to READY
- ✓ Power charge is cancelled
- ✓ Ball returns to start position
- ✓ Reset completes within 0.5s

### Test 14: Reset During Flight

**Objective:** Verify reset works while ball is in flight

**Steps:**
1. Execute a strike
2. Press R while ball is in flight
3. Observe

**Expected:**
- ✓ State returns to READY
- ✓ Ball immediately returns to start position
- ✓ Ball velocity is cleared
- ✓ Reset completes within 0.5s

**Success Criteria:**
- Reset works from any state
- Reset completes quickly (< 0.5s)
- All state is properly cleared
- Reset feels natural and responsive

---

## Feel Assessment

After completing all tests, assess the overall "feel" of the strike mechanics:

### 1. Aim Responsiveness

**Questions:**
- Does the aim update immediately when you press keys?
- Is the aim cone appropriate (not too wide or narrow)?
- Does aiming feel precise and controllable?

**Rating:** ☐ Excellent ☐ Good ☐ Needs Adjustment

**Notes:**

---

### 2. Power Charge Feel

**Questions:**
- Is 1.5 seconds a good duration for full charge?
- Is the power progression smooth and predictable?
- Can you consistently hit your target power level?

**Rating:** ☐ Excellent ☐ Good ☐ Needs Adjustment

**Notes:**

---

### 3. Contact Timing

**Questions:**
- Can you feel the difference between perfect and scuffed timing?
- Is the optimal timing window (90-100%) intuitive?
- Does timing feel meaningful and rewarding?

**Rating:** ☐ Excellent ☐ Good ☐ Needs Adjustment

**Notes:**

---

### 4. Ball Physics

**Questions:**
- Does the ball speed feel appropriate?
- Is the drift based on quality noticeable but not excessive?
- Does the ball behavior feel realistic?

**Rating:** ☐ Excellent ☐ Good ☐ Needs Adjustment

**Notes:**

---

### 5. Goal Detection

**Questions:**
- Does goal detection trigger at the right moment?
- Are the goal boundaries clear and consistent?
- Does the detection feel accurate?

**Rating:** ☐ Excellent ☐ Good ☐ Needs Adjustment

**Notes:**

---

### 6. Overall Flow

**Questions:**
- Are state transitions smooth and natural?
- Does the reset feel responsive?
- Is the overall experience enjoyable?
- Would you replay shots to improve?

**Rating:** ☐ Excellent ☐ Good ☐ Needs Adjustment

**Notes:**

---

## Validation Checklist

Use this checklist to track testing progress:

### Core Mechanics
- [ ] Complete strike flow works (aim → charge → contact → flight → outcome)
- [ ] Ball physics responds correctly to contact quality
- [ ] Power charge system works correctly
- [ ] Aim system is responsive and accurate

### Goal Detection
- [ ] Goal detection works for center shots
- [ ] Misses are detected outside width boundaries
- [ ] Misses are detected above height boundaries
- [ ] Entry position is accurately calculated

### Top Bins
- [ ] Top Bins detected in top left corner
- [ ] Top Bins detected in top right corner
- [ ] Top Bins NOT detected in top center
- [ ] Top Bins NOT detected in bottom corners

### Reset & State Management
- [ ] Reset works from aiming state
- [ ] Reset works from charging state
- [ ] Reset works from flight state
- [ ] State transitions function properly

### Feel & Polish
- [ ] Input is responsive (< 1 frame delay)
- [ ] No crashes or errors during testing
- [ ] Overall experience feels smooth
- [ ] Strike mechanics feel intentional and rewarding

---

## Known Limitations

The following features are intentionally not implemented yet:

- ❌ Audio feedback (Task 12)
- ❌ Camera feedback (Task 13)
- ❌ Scoring system (Task 14)
- ❌ UI feedback (Task 15)
- ❌ Statistics tracking (Task 18)

These will be added in subsequent development phases.

---

## Troubleshooting

### Issue: Ball doesn't move after strike

**Possible Causes:**
- Power level below 20% threshold
- Strike rejected due to low power

**Solution:**
- Check console for "Strike rejected: Power too low"
- Ensure power is charged to at least 20%

---

### Issue: Goal not detected

**Possible Causes:**
- Ball not crossing goal line (Z = 40)
- Ball outside goal boundaries

**Solution:**
- Verify ball crosses goal line in console output
- Check ball is within goal boundaries:
  - Width: -3.66m to +3.66m
  - Height: 0m to 2.44m

---

### Issue: State not transitioning

**Possible Causes:**
- Input actions not properly configured
- Script errors preventing state changes

**Solution:**
- Check console for state change messages
- Verify input actions in project settings
- Look for script errors in console

---

### Issue: Script errors on load

**Possible Causes:**
- Missing core system scripts
- Incorrect scene references

**Solution:**
- Ensure all scripts are present in scripts/ directory
- Verify scene references in practice_mode.tscn
- Check console for specific error messages

---

## Reporting Issues

When reporting issues, please include:

1. **Test being performed** (e.g., "Test 2a: Perfect Contact")
2. **Expected behavior** (from test description)
3. **Actual behavior** (what actually happened)
4. **Console output** (any error messages or logs)
5. **Steps to reproduce** (exact sequence of inputs)

This helps identify and fix issues quickly.
