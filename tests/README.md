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
# Run all tests
tools\run_all_tests.bat

# Run specific test categories
tools\run_data_model_tests.bat
tools\run_feedback_tests.bat
tools\run_scene_init_tests.bat
tools\run_stats_tracker_test.bat
```

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
- ⏳ Contact quality consistency (Property 2)
- ⏳ Goal detection (Property 3)
- ⏳ Top Bins detection (Property 4)
- ⏳ Scoring calculation (Property 5)

### Unit Tests

- ✅ Scene initialization
- ✅ Stats tracker

### Integration Tests

- ✅ Feedback coordination
- ✅ Strike flow validation

## Best Practices

1. **Keep tests focused**: One test per property or behavior
2. **Use descriptive names**: Test names should explain what they validate
3. **Reference requirements**: Include requirement numbers in comments
4. **Minimize dependencies**: Tests should be independent when possible
5. **Clean up resources**: Properly free nodes and resources after tests
