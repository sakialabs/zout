# Tests

This directory contains all test files for the Zout Practice Mode MVP.

## Test Organization

Tests are organized by type to maintain clarity and follow best practices:

```plaintext
tests/
├── unit/              # Unit tests for individual components
├── property/          # Property-based tests (PBT) for universal properties
├── integration/       # Integration tests for system coordination
├── scenes/            # Test scenes (.tscn files)
└── README.md          # This file
```

## Test Types

### Unit Tests (`unit/`)

Test specific examples, edge cases, and error conditions for individual components.

- Focus on concrete behavior
- Test boundary conditions
- Validate error handling

### Property-Based Tests (`property/`)

Test universal properties that should hold across all inputs.

- Minimum 100 iterations per test
- Random input generation
- Validates design document properties

### Integration Tests (`integration/`)

Test coordination between multiple systems.

- End-to-end workflows
- System interactions
- Feedback coordination

### Test Scenes (`scenes/`)

Godot scene files (.tscn) that load and run test scripts.

- One scene per test script
- Minimal scene setup
- References test scripts from appropriate folders

## Running Tests

Use the batch files in `tools/` to run tests:

```bash
# Run all core mechanics tests (NEW - Tasks 3.1, 3.2, 4.1, 5.1, 6.1)
tools\run_core_mechanics_tests.bat

# Run all tests
tools\run_all_tests.bat

# Run specific test categories
tools\run_data_model_tests.bat
tools\run_feedback_tests.bat
tools\run_scene_init_tests.bat
tools\run_stats_tracker_test.bat

# Run individual core mechanics tests
tools\run_timing_windows_test.bat
tools\run_contact_quality_test.bat
tools\run_aim_clamping_test.bat
tools\run_power_charging_test.bat
tools\run_timing_evaluation_test.bat
```

## Quick Test Reference

See **Quick Test Reference** at bottom of this file for rapid testing commands.

## Test Naming Convention

- Test files: `test_<feature_name>.gd`
- Test scenes: `test_<feature_name>.tscn`
- Test classes: `Test<FeatureName>`

## Writing New Tests

1. Determine test type (unit, property, or integration)
2. Create test script in appropriate folder
3. Create corresponding scene in `tests/scenes/`
4. Add batch file in `tools/` if needed
5. Update this README

## Current Test Coverage

### Property-Based Tests

- ✅ Data model integrity (Property 1)
- ✅ Contact quality consistency (Property 2) - **NEW: Task 3.2**
- ⏳ Goal detection (Property 3)
- ⏳ Top Bins detection (Property 4)
- ⏳ Scoring calculation (Property 5)

### Unit Tests

- ✅ Scene initialization
- ✅ Stats tracker
- ✅ Timing windows (ContactQualityCalculator) - **NEW: Task 3.1**
- ✅ Aim clamping (AimSystem) - **NEW: Task 4.1**
- ✅ Power charging (PowerSystem) - **NEW: Task 5.1**
- ✅ Timing evaluation (TimingSystem) - **NEW: Task 6.1**

### Integration Tests

- ✅ Feedback coordination
- ✅ Strike flow validation

---

## 🧪 Quick Test Reference

### Run All Core Mechanics Tests
```bash
cd tools
run_core_mechanics_tests.bat
```

### Run Individual Test Suites

**Timing Windows (Task 3.1)**
```bash
tools\run_timing_windows_test.bat
```
Validates: Perfect/Clean/Okay/Scuffed timing windows and boundaries

**Contact Quality Properties (Task 3.2)**
```bash
tools\run_contact_quality_test.bat
```
Validates: Quality consistency, multipliers, thresholds (100 random tests)

**Aim Clamping (Task 4.1)**
```bash
tools\run_aim_clamping_test.bat
```
Validates: 45° horizontal, 30° vertical cone, input clamping

**Power Charging (Task 5.1)**
```bash
tools\run_power_charging_test.bat
```
Validates: Linear charging, 20% threshold, 100% clamping

**Timing Evaluation (Task 6.1)**
```bash
tools\run_timing_evaluation_test.bat
```
Validates: Optimal timing at 95%, offset calculations

### Expected Results

✅ **All Tests Should Pass:**
- Timing Windows: 20/20 tests
- Contact Quality: 4/4 properties  
- Aim Clamping: 15/15 tests
- Power Charging: 15/15 tests
- Timing Evaluation: 20/20 tests

**Total: 74+ tests, all passing**

### Full Documentation

See [docs/TEST_SUITE.md](../docs/TEST_SUITE.md) for comprehensive test documentation.

## Best Practices

1. **Keep tests focused**: One test per property or behavior
2. **Use descriptive names**: Test names should explain what they validate
3. **Reference requirements**: Include requirement numbers in comments
4. **Minimize dependencies**: Tests should be independent when possible
5. **Clean up resources**: Properly free nodes and resources after tests
