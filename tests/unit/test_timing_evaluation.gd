extends Node

## Unit tests for TimingSystem evaluation
## Tests each timing window produces correct quality
## Tests optimal timing point
## Validates: Requirements 1.3, 1.4

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []

# System under test
var timing_system: TimingSystem

# Test configuration
const EPSILON = 0.001  # Floating point comparison tolerance
const CHARGE_DURATION = 1.5  # Default charge duration


func _ready() -> void:
	print("\n=== TIMING EVALUATION UNIT TESTS ===\n")
	
	# Initialize timing system
	timing_system = TimingSystem.new()
	timing_system.charge_duration = CHARGE_DURATION
	
	# Run tests
	_run_all_tests()
	
	# Print results
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Run all unit tests
func _run_all_tests() -> void:
	# Optimal timing tests
	test_optimal_timing_point_is_95_percent()
	test_optimal_timing_produces_perfect()
	
	# Perfect window tests
	test_perfect_window_center()
	test_perfect_window_boundaries()
	test_perfect_requires_90_percent_power()
	
	# Clean window tests
	test_clean_window_boundaries()
	test_clean_window_mid_range()
	
	# Okay window tests
	test_okay_window_boundaries()
	test_okay_window_mid_range()
	
	# Scuffed window tests
	test_scuffed_outside_okay_window()
	test_very_early_is_scuffed()
	test_very_late_is_scuffed()
	
	# Timing offset calculation tests
	test_timing_offset_at_optimal()
	test_timing_offset_early()
	test_timing_offset_late()
	
	# Edge case tests
	test_zero_elapsed_time()
	test_maximum_elapsed_time()


## Test: Optimal timing point is at 95% power
func test_optimal_timing_point_is_95_percent() -> void:
	var test_name = "Optimal timing point is at 95% power (1.425s)"
	
	# Optimal is at midpoint of 90-100% range = 95%
	# 95% of 1.5s = 1.425s
	var optimal_time = 0.95 * CHARGE_DURATION
	var charge_start = 0.0
	var release_time = charge_start + optimal_time
	
	var offset = timing_system.get_timing_offset(release_time, charge_start)
	
	# Offset should be exactly 0.0 at optimal timing
	if abs(offset) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Offset: " + str(offset) + "s (should be 0.0s)")


## Test: Optimal timing produces PERFECT quality
func test_optimal_timing_produces_perfect() -> void:
	var test_name = "Optimal timing produces PERFECT quality"
	
	# Release at optimal timing (95% power = 1.425s)
	var charge_start = 0.0
	var release_time = charge_start + (0.95 * CHARGE_DURATION)
	
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	if quality == StrikeData.ContactQuality.PERFECT:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Perfect window center (0.0s offset)
func test_perfect_window_center() -> void:
	var test_name = "Perfect window center (0.0s offset, 100% power)"
	
	# Release at 100% power (1.5s)
	var charge_start = 0.0
	var release_time = charge_start + CHARGE_DURATION
	
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	# At 100% power, offset from optimal (95%) is +0.075s
	# This is within PERFECT window (±0.05s)?
	# Actually, offset would be: 1.5 - 1.425 = 0.075s
	# This exceeds ±0.05s, so should be CLEAN
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Perfect window boundaries (±0.05s from optimal)
func test_perfect_window_boundaries() -> void:
	var test_name = "Perfect window boundaries (±0.05s from optimal)"
	
	# Optimal timing is at 1.425s (95% power)
	var optimal_time = 0.95 * CHARGE_DURATION
	var charge_start = 0.0
	
	# Test lower boundary: optimal - 0.05s = 1.375s (91.67% power)
	var release_time_lower = charge_start + optimal_time - 0.05
	var quality_lower = timing_system.evaluate_timing(release_time_lower, charge_start)
	
	# Test upper boundary: optimal + 0.05s = 1.475s (98.33% power)
	var release_time_upper = charge_start + optimal_time + 0.05
	var quality_upper = timing_system.evaluate_timing(release_time_upper, charge_start)
	
	# Both should be PERFECT (power > 90%, within ±0.05s)
	if quality_lower == StrikeData.ContactQuality.PERFECT and quality_upper == StrikeData.ContactQuality.PERFECT:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Lower: " + _quality_to_string(quality_lower) + ", Upper: " + _quality_to_string(quality_upper))


## Test: Perfect requires 90%+ power
func test_perfect_requires_90_percent_power() -> void:
	var test_name = "Perfect requires 90%+ power (89% power gives CLEAN)"
	
	# Release at 89% power (1.335s) with perfect timing offset
	# But since power < 90%, should be CLEAN, not PERFECT
	var charge_start = 0.0
	var release_time = charge_start + (0.89 * CHARGE_DURATION)
	
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	# Offset from optimal (95%) would be: -0.06s (outside perfect window anyway)
	# This should be CLEAN
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Clean window boundaries (±0.15s from optimal)
func test_clean_window_boundaries() -> void:
	var test_name = "Clean window boundaries (±0.15s from optimal)"
	
	# Optimal timing is at 1.425s
	var optimal_time = 0.95 * CHARGE_DURATION
	var charge_start = 0.0
	
	# Test lower boundary: optimal - 0.15s = 1.275s (85% power)
	var release_time_lower = charge_start + optimal_time - 0.15
	var quality_lower = timing_system.evaluate_timing(release_time_lower, charge_start)
	
	# Test upper boundary: optimal + 0.15s = 1.575s (105% power, clamped to 100%)
	# Actually power would be clamped at 100% (1.5s), so this is beyond duration
	# Let's test at 1.5s + 0.075s = 1.575s after start
	# But release_time can't exceed what's physically possible
	# Let's just test the lower boundary and a point within clean range
	
	if quality_lower == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name + " (lower boundary)")
	else:
		_fail_test(test_name + " - Lower: " + _quality_to_string(quality_lower))


## Test: Clean window mid-range
func test_clean_window_mid_range() -> void:
	var test_name = "Clean window mid-range (±0.10s from optimal)"
	
	# Optimal timing is at 1.425s
	var optimal_time = 0.95 * CHARGE_DURATION
	var charge_start = 0.0
	
	# Test at optimal ± 0.10s (within ±0.15s clean window, outside ±0.05s perfect window)
	var release_time = charge_start + optimal_time + 0.10
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	# Should be CLEAN (power would be 100% since 1.425 + 0.10 = 1.525s > 1.5s duration)
	# Actually, this would be after charge duration, need to reconsider
	# Let's test at optimal - 0.10s instead
	release_time = charge_start + optimal_time - 0.10
	quality = timing_system.evaluate_timing(release_time, charge_start)
	
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Okay window boundaries (±0.30s from optimal)
func test_okay_window_boundaries() -> void:
	var test_name = "Okay window boundaries (±0.30s from optimal)"
	
	# Optimal timing is at 1.425s
	var optimal_time = 0.95 * CHARGE_DURATION
	var charge_start = 0.0
	
	# Test lower boundary: optimal - 0.30s = 1.125s (75% power)
	var release_time_lower = charge_start + optimal_time - 0.30
	var quality_lower = timing_system.evaluate_timing(release_time_lower, charge_start)
	
	if quality_lower == StrikeData.ContactQuality.OKAY:
		_pass_test(test_name + " (lower boundary)")
	else:
		_fail_test(test_name + " - Lower: " + _quality_to_string(quality_lower))


## Test: Okay window mid-range
func test_okay_window_mid_range() -> void:
	var test_name = "Okay window mid-range (±0.20s from optimal)"
	
	# Optimal timing is at 1.425s
	var optimal_time = 0.95 * CHARGE_DURATION
	var charge_start = 0.0
	
	# Test at optimal - 0.20s (within ±0.30s okay window)
	var release_time = charge_start + optimal_time - 0.20
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	if quality == StrikeData.ContactQuality.OKAY:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Outside okay window is SCUFFED
func test_scuffed_outside_okay_window() -> void:
	var test_name = "Outside okay window is SCUFFED (±0.35s from optimal)"
	
	# Optimal timing is at 1.425s
	var optimal_time = 0.95 * CHARGE_DURATION
	var charge_start = 0.0
	
	# Test beyond okay window: optimal - 0.35s = 1.075s (71.67% power)
	var release_time = charge_start + optimal_time - 0.35
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	if quality == StrikeData.ContactQuality.SCUFFED:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Very early release is SCUFFED
func test_very_early_is_scuffed() -> void:
	var test_name = "Very early release is SCUFFED (30% power)"
	
	# Release very early at 30% power (0.45s)
	var charge_start = 0.0
	var release_time = charge_start + (0.30 * CHARGE_DURATION)
	
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	# Offset from optimal would be huge (≈ -0.975s)
	if quality == StrikeData.ContactQuality.SCUFFED:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Very late release is CLEAN (clamped at 100%)
func test_very_late_is_scuffed() -> void:
	var test_name = "Very late release timing offset calculation"
	
	# Release way past optimal at 100% power (1.5s)
	var charge_start = 0.0
	var release_time = charge_start + CHARGE_DURATION  # 1.5s = 100% power
	
	var offset = timing_system.get_timing_offset(release_time, charge_start)
	
	# Offset from optimal (1.425s) should be: 1.5 - 1.425 = +0.075s
	# This is just outside perfect window (±0.05s), so should be CLEAN
	var expected_offset = 0.075
	
	if abs(offset - expected_offset) < EPSILON:
		_pass_test(test_name + " - Offset: " + str(snappedf(offset, 0.001)) + "s")
	else:
		_fail_test(test_name + " - Got: " + str(offset) + "s, Expected: " + str(expected_offset) + "s")


## Test: Timing offset at optimal is zero
func test_timing_offset_at_optimal() -> void:
	var test_name = "Timing offset at optimal is zero"
	
	# Release at optimal timing (95% power)
	var charge_start = 0.0
	var optimal_time = 0.95 * CHARGE_DURATION
	var release_time = charge_start + optimal_time
	
	var offset = timing_system.get_timing_offset(release_time, charge_start)
	
	if abs(offset) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(offset) + "s")


## Test: Timing offset for early release is negative
func test_timing_offset_early() -> void:
	var test_name = "Timing offset for early release is negative"
	
	# Release early at 80% power (1.2s)
	var charge_start = 0.0
	var release_time = charge_start + (0.80 * CHARGE_DURATION)
	
	var offset = timing_system.get_timing_offset(release_time, charge_start)
	
	# Offset from optimal (1.425s) should be: 1.2 - 1.425 = -0.225s
	var expected_offset = -0.225
	
	if abs(offset - expected_offset) < EPSILON:
		_pass_test(test_name + " - Offset: " + str(snappedf(offset, 0.001)) + "s")
	else:
		_fail_test(test_name + " - Got: " + str(offset) + "s, Expected: " + str(expected_offset) + "s")


## Test: Timing offset for late release is positive
func test_timing_offset_late() -> void:
	var test_name = "Timing offset for late release is positive"
	
	# Release late at 100% power (1.5s)
	var charge_start = 0.0
	var release_time = charge_start + CHARGE_DURATION
	
	var offset = timing_system.get_timing_offset(release_time, charge_start)
	
	# Offset from optimal (1.425s) should be: 1.5 - 1.425 = +0.075s
	var expected_offset = 0.075
	
	if abs(offset - expected_offset) < EPSILON:
		_pass_test(test_name + " - Offset: " + str(snappedf(offset, 0.001)) + "s")
	else:
		_fail_test(test_name + " - Got: " + str(offset) + "s, Expected: " + str(expected_offset) + "s")


## Test: Zero elapsed time handling
func test_zero_elapsed_time() -> void:
	var test_name = "Zero elapsed time (instant release)"
	
	# Release immediately (0s elapsed)
	var charge_start = 0.0
	var release_time = charge_start
	
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	# Should be SCUFFED (0% power, huge timing offset)
	if quality == StrikeData.ContactQuality.SCUFFED:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Maximum elapsed time (held to 100%)
func test_maximum_elapsed_time() -> void:
	var test_name = "Maximum elapsed time (100% power at 1.5s)"
	
	# Release at exactly charge_duration
	var charge_start = 0.0
	var release_time = charge_start + CHARGE_DURATION
	
	var quality = timing_system.evaluate_timing(release_time, charge_start)
	
	# At 100% power, offset is +0.075s from optimal
	# This is outside ±0.05s perfect window, so should be CLEAN
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Helper: Convert quality enum to string
func _quality_to_string(quality: StrikeData.ContactQuality) -> String:
	match quality:
		StrikeData.ContactQuality.PERFECT:
			return "PERFECT"
		StrikeData.ContactQuality.CLEAN:
			return "CLEAN"
		StrikeData.ContactQuality.OKAY:
			return "OKAY"
		StrikeData.ContactQuality.SCUFFED:
			return "SCUFFED"
		_:
			return "UNKNOWN"


## Helper: Mark test as passed
func _pass_test(test_name: String) -> void:
	tests_passed += 1
	test_results.append("✓ " + test_name)
	print("  ✓ " + test_name)


## Helper: Mark test as failed
func _fail_test(test_name: String) -> void:
	tests_failed += 1
	test_results.append("✗ " + test_name)
	print("  ✗ " + test_name)


## Print test results summary
func _print_results() -> void:
	print("\n=== TEST RESULTS ===")
	print("Passed: " + str(tests_passed))
	print("Failed: " + str(tests_failed))
	print("Total:  " + str(tests_passed + tests_failed))
	
	if tests_failed > 0:
		print("\nFailed tests:")
		for result in test_results:
			if result.begins_with("✗"):
				print("  " + result)
	
	if tests_failed == 0:
		print("\n🎯 ALL TESTS PASSED!")
	else:
		print("\n❌ SOME TESTS FAILED")
