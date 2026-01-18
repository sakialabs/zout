extends Node

## Unit tests for PowerSystem charging behavior
## Tests power reaches 100% at charge_duration
## Tests power rejection below 20%
## Tests power clamps at 100% when held
## Validates: Requirements 1.2

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []

# System under test
var power_system: PowerSystem

# Test configuration
const EPSILON = 0.01  # 1% tolerance for power measurements
const CHARGE_DURATION = 1.5  # Default charge duration


func _ready() -> void:
	print("\n=== POWER CHARGING UNIT TESTS ===\n")
	
	# Initialize power system
	power_system = PowerSystem.new()
	
	# Run tests
	await _run_all_tests()
	
	# Print results
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Run all unit tests
func _run_all_tests() -> void:
	# Basic charging tests
	await test_power_starts_at_zero()
	await test_power_reaches_100_at_duration()
	await test_power_linear_accumulation()
	
	# Threshold tests
	await test_power_rejection_below_20_percent()
	await test_power_at_exactly_20_percent()
	await test_power_just_below_20_percent()
	
	# Clamping tests
	await test_power_clamps_at_100_when_held()
	await test_power_clamps_when_overcharged()
	
	# Release behavior tests
	await test_release_before_charging_returns_zero()
	await test_release_returns_final_power()
	await test_release_stops_charging()
	
	# Edge case tests
	await test_multiple_charge_cycles()
	await test_instant_release_rejected()


## Test: Power starts at zero before charging
func test_power_starts_at_zero() -> void:
	var test_name = "Power starts at zero before charging"
	
	var initial_power = power_system.get_current_power()
	
	if abs(initial_power) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(initial_power))


## Test: Power reaches 100% at charge_duration
func test_power_reaches_100_at_duration() -> void:
	var test_name = "Power reaches 100% at charge_duration (1.5s)"
	
	# Start charging
	power_system.start_charge()
	
	# Wait exactly charge_duration
	await get_tree().create_timer(CHARGE_DURATION).timeout
	
	var final_power = power_system.get_current_power()
	
	# Should be at or very close to 100%
	if abs(final_power - 1.0) < EPSILON:
		_pass_test(test_name + " - Power: " + str(snappedf(final_power * 100, 0.1)) + "%")
	else:
		_fail_test(test_name + " - Got: " + str(final_power * 100) + "%")
	
	# Clean up
	power_system.release_charge()


## Test: Power accumulates linearly
func test_power_linear_accumulation() -> void:
	var test_name = "Power accumulates linearly over time"
	
	# Start charging
	power_system.start_charge()
	
	# Sample power at different intervals
	var samples = []
	var intervals = [0.3, 0.6, 0.9, 1.2]  # 20%, 40%, 60%, 80% of charge_duration
	
	for interval in intervals:
		await get_tree().create_timer(0.3).timeout  # Wait 0.3s between samples
		var power = power_system.get_current_power()
		samples.append(power)
	
	# Verify linear progression
	var is_linear = true
	for i in range(samples.size() - 1):
		var diff = samples[i + 1] - samples[i]
		# Each 0.3s step should increase power by ~20% (0.3/1.5)
		var expected_diff = 0.3 / CHARGE_DURATION
		if abs(diff - expected_diff) > 0.05:  # Allow 5% tolerance
			is_linear = false
			break
	
	if is_linear:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Samples: " + str(samples))
	
	# Clean up
	power_system.release_charge()


## Test: Power below 20% is rejected
func test_power_rejection_below_20_percent() -> void:
	var test_name = "Power below 20% is rejected on release"
	
	# Start charging
	power_system.start_charge()
	
	# Wait for ~10% power (0.15s)
	await get_tree().create_timer(0.15).timeout
	
	# Release should return -1.0 (rejected)
	var released_power = power_system.release_charge()
	
	if released_power == -1.0:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(released_power))


## Test: Power at exactly 20% is accepted
func test_power_at_exactly_20_percent() -> void:
	var test_name = "Power at exactly 20% is accepted"
	
	# Start charging
	power_system.start_charge()
	
	# Wait for exactly 20% power (0.3s = 20% of 1.5s)
	await get_tree().create_timer(0.3).timeout
	
	# Release should return the power level
	var released_power = power_system.release_charge()
	
	if released_power >= 0.20 and released_power != -1.0:
		_pass_test(test_name + " - Power: " + str(snappedf(released_power * 100, 0.1)) + "%")
	else:
		_fail_test(test_name + " - Got: " + str(released_power))


## Test: Power just below 20% is rejected
func test_power_just_below_20_percent() -> void:
	var test_name = "Power just below 20% is rejected (19.9%)"
	
	# Start charging
	power_system.start_charge()
	
	# Wait for ~19% power (0.285s)
	await get_tree().create_timer(0.285).timeout
	
	# Release should return -1.0 (rejected)
	var released_power = power_system.release_charge()
	
	if released_power == -1.0:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(released_power) + " (should be -1.0)")


## Test: Power clamps at 100% when held
func test_power_clamps_at_100_when_held() -> void:
	var test_name = "Power clamps at 100% when held past duration"
	
	# Start charging
	power_system.start_charge()
	
	# Wait past charge_duration (2.0s > 1.5s)
	await get_tree().create_timer(2.0).timeout
	
	var power = power_system.get_current_power()
	
	# Should be clamped at 100%
	if abs(power - 1.0) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(power * 100) + "%")
	
	# Clean up
	power_system.release_charge()


## Test: Power clamps when overcharged
func test_power_clamps_when_overcharged() -> void:
	var test_name = "Power clamps when significantly overcharged (3.0s)"
	
	# Start charging
	power_system.start_charge()
	
	# Wait way past charge_duration
	await get_tree().create_timer(3.0).timeout
	
	var released_power = power_system.release_charge()
	
	# Should be clamped at 100%
	if abs(released_power - 1.0) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(released_power * 100) + "%")


## Test: Release before charging returns zero
func test_release_before_charging_returns_zero() -> void:
	var test_name = "Release before charging returns zero"
	
	# Don't start charging, just release
	var released_power = power_system.release_charge()
	
	if abs(released_power) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(released_power))


## Test: Release returns final power level
func test_release_returns_final_power() -> void:
	var test_name = "Release returns final power level"
	
	# Start charging
	power_system.start_charge()
	
	# Wait for 50% power (0.75s)
	await get_tree().create_timer(0.75).timeout
	
	var released_power = power_system.release_charge()
	
	# Should be around 50%
	if abs(released_power - 0.5) < 0.05:  # 5% tolerance
		_pass_test(test_name + " - Power: " + str(snappedf(released_power * 100, 0.1)) + "%")
	else:
		_fail_test(test_name + " - Got: " + str(released_power * 100) + "% (expected ~50%)")


## Test: Release stops charging
func test_release_stops_charging() -> void:
	var test_name = "Release stops charging (power doesn't increase after release)"
	
	# Start charging
	power_system.start_charge()
	
	# Wait a bit
	await get_tree().create_timer(0.5).timeout
	
	# Release
	var released_power = power_system.release_charge()
	
	# Wait more time
	await get_tree().create_timer(0.5).timeout
	
	# Get current power - should still be 0 (charging stopped)
	var current_power = power_system.get_current_power()
	
	if abs(current_power) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Power continued charging: " + str(current_power))


## Test: Multiple charge cycles work independently
func test_multiple_charge_cycles() -> void:
	var test_name = "Multiple charge cycles work independently"
	
	# First cycle
	power_system.start_charge()
	await get_tree().create_timer(0.5).timeout
	var power1 = power_system.release_charge()
	
	# Second cycle
	power_system.start_charge()
	await get_tree().create_timer(0.5).timeout
	var power2 = power_system.release_charge()
	
	# Both should be similar (around 33% each)
	if abs(power1 - power2) < 0.1:  # 10% tolerance
		_pass_test(test_name + " - Cycle 1: " + str(snappedf(power1 * 100, 0.1)) + "%, Cycle 2: " + str(snappedf(power2 * 100, 0.1)) + "%")
	else:
		_fail_test(test_name + " - Inconsistent: " + str(power1) + " vs " + str(power2))


## Test: Instant release is rejected (too fast)
func test_instant_release_rejected() -> void:
	var test_name = "Instant release is rejected (< 20% power)"
	
	# Start and immediately release
	power_system.start_charge()
	await get_tree().process_frame  # Wait 1 frame (~0.016s)
	var released_power = power_system.release_charge()
	
	# Should be rejected
	if released_power == -1.0:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(released_power))


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
