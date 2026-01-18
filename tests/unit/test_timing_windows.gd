extends Node

## Unit tests for ContactQualityCalculator timing windows
## Tests boundary conditions for each quality level
## Tests edge cases (0% power, 100% power, exact optimal timing)
## Validates: Requirements 1.4, 2.1, 2.2, 2.3, 2.4

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []

# System under test
var calculator: ContactQualityCalculator


func _ready() -> void:
	print("\n=== TIMING WINDOWS UNIT TESTS ===\n")
	
	# Initialize calculator
	calculator = ContactQualityCalculator.new()
	
	# Run tests
	_run_all_tests()
	
	# Print results
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Run all unit tests
func _run_all_tests() -> void:
	# Perfect window boundary tests
	test_perfect_window_exact_center()
	test_perfect_window_lower_boundary()
	test_perfect_window_upper_boundary()
	test_perfect_window_just_outside_lower()
	test_perfect_window_just_outside_upper()
	
	# Clean window boundary tests
	test_clean_window_lower_boundary()
	test_clean_window_upper_boundary()
	test_clean_window_just_outside_lower()
	test_clean_window_just_outside_upper()
	
	# Okay window boundary tests
	test_okay_window_lower_boundary()
	test_okay_window_upper_boundary()
	test_okay_window_just_outside()
	
	# Power threshold tests
	test_zero_power_rejected()
	test_minimum_power_threshold()
	test_just_below_minimum_power()
	test_maximum_power_perfect_timing()
	test_maximum_power_clean_timing()
	
	# Perfect quality requirements
	test_perfect_requires_optimal_power()
	test_perfect_timing_with_low_power_is_clean()


## Test: Perfect window exact center (0.0s offset)
func test_perfect_window_exact_center() -> void:
	var test_name = "Perfect window exact center (0.0s offset, 100% power)"
	var quality = calculator.calculate_quality(1.0, 0.0)
	
	if quality == StrikeData.ContactQuality.PERFECT:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Perfect window lower boundary (-0.05s)
func test_perfect_window_lower_boundary() -> void:
	var test_name = "Perfect window lower boundary (-0.05s, 100% power)"
	var quality = calculator.calculate_quality(1.0, -0.05)
	
	if quality == StrikeData.ContactQuality.PERFECT:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Perfect window upper boundary (+0.05s)
func test_perfect_window_upper_boundary() -> void:
	var test_name = "Perfect window upper boundary (+0.05s, 100% power)"
	var quality = calculator.calculate_quality(1.0, 0.05)
	
	if quality == StrikeData.ContactQuality.PERFECT:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Just outside perfect window lower (-0.051s)
func test_perfect_window_just_outside_lower() -> void:
	var test_name = "Just outside perfect window lower (-0.051s, 100% power)"
	var quality = calculator.calculate_quality(1.0, -0.051)
	
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Just outside perfect window upper (+0.051s)
func test_perfect_window_just_outside_upper() -> void:
	var test_name = "Just outside perfect window upper (+0.051s, 100% power)"
	var quality = calculator.calculate_quality(1.0, 0.051)
	
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Clean window lower boundary (-0.15s)
func test_clean_window_lower_boundary() -> void:
	var test_name = "Clean window lower boundary (-0.15s, 50% power)"
	var quality = calculator.calculate_quality(0.5, -0.15)
	
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Clean window upper boundary (+0.15s)
func test_clean_window_upper_boundary() -> void:
	var test_name = "Clean window upper boundary (+0.15s, 50% power)"
	var quality = calculator.calculate_quality(0.5, 0.15)
	
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Just outside clean window lower (-0.151s)
func test_clean_window_just_outside_lower() -> void:
	var test_name = "Just outside clean window lower (-0.151s, 50% power)"
	var quality = calculator.calculate_quality(0.5, -0.151)
	
	if quality == StrikeData.ContactQuality.OKAY:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Just outside clean window upper (+0.151s)
func test_clean_window_just_outside_upper() -> void:
	var test_name = "Just outside clean window upper (+0.151s, 50% power)"
	var quality = calculator.calculate_quality(0.5, 0.151)
	
	if quality == StrikeData.ContactQuality.OKAY:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Okay window lower boundary (-0.30s)
func test_okay_window_lower_boundary() -> void:
	var test_name = "Okay window lower boundary (-0.30s, 50% power)"
	var quality = calculator.calculate_quality(0.5, -0.30)
	
	if quality == StrikeData.ContactQuality.OKAY:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Okay window upper boundary (+0.30s)
func test_okay_window_upper_boundary() -> void:
	var test_name = "Okay window upper boundary (+0.30s, 50% power)"
	var quality = calculator.calculate_quality(0.5, 0.30)
	
	if quality == StrikeData.ContactQuality.OKAY:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Just outside okay window (+0.31s)
func test_okay_window_just_outside() -> void:
	var test_name = "Just outside okay window (+0.31s, 50% power)"
	var quality = calculator.calculate_quality(0.5, 0.31)
	
	if quality == StrikeData.ContactQuality.SCUFFED:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Zero power is rejected (SCUFFED)
func test_zero_power_rejected() -> void:
	var test_name = "Zero power is rejected (0% power, perfect timing)"
	var quality = calculator.calculate_quality(0.0, 0.0)
	
	if quality == StrikeData.ContactQuality.SCUFFED:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Minimum power threshold (20% exactly)
func test_minimum_power_threshold() -> void:
	var test_name = "Minimum power threshold (20% power, perfect timing)"
	var quality = calculator.calculate_quality(0.20, 0.0)
	
	# At 20% power with perfect timing, should be CLEAN (not enough for PERFECT)
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Just below minimum power (19.9%)
func test_just_below_minimum_power() -> void:
	var test_name = "Just below minimum power (19.9% power, perfect timing)"
	var quality = calculator.calculate_quality(0.199, 0.0)
	
	if quality == StrikeData.ContactQuality.SCUFFED:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Maximum power with perfect timing
func test_maximum_power_perfect_timing() -> void:
	var test_name = "Maximum power with perfect timing (100% power, 0.0s offset)"
	var quality = calculator.calculate_quality(1.0, 0.0)
	
	if quality == StrikeData.ContactQuality.PERFECT:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Maximum power with clean timing
func test_maximum_power_clean_timing() -> void:
	var test_name = "Maximum power with clean timing (100% power, 0.1s offset)"
	var quality = calculator.calculate_quality(1.0, 0.1)
	
	if quality == StrikeData.ContactQuality.CLEAN:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Perfect requires optimal power (90%+)
func test_perfect_requires_optimal_power() -> void:
	var test_name = "Perfect requires optimal power (90% power, 0.0s offset)"
	var quality = calculator.calculate_quality(0.90, 0.0)
	
	if quality == StrikeData.ContactQuality.PERFECT:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + _quality_to_string(quality))


## Test: Perfect timing with low power is CLEAN
func test_perfect_timing_with_low_power_is_clean() -> void:
	var test_name = "Perfect timing with low power is CLEAN (50% power, 0.0s offset)"
	var quality = calculator.calculate_quality(0.5, 0.0)
	
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
