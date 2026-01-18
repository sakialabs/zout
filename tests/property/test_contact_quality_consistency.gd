extends Node

## Property test for contact quality consistency
## Property 2: Contact quality determines ball behavior consistently
## Validates: Requirements 2.1, 2.2, 2.3, 2.4
## Generates random timing offsets, verifies quality assignment matches windows

# Test configuration
const NUM_RANDOM_TESTS = 100  # Number of random test cases
const EPSILON = 0.0001  # Floating point comparison tolerance

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []

# System under test
var calculator: ContactQualityCalculator


func _ready() -> void:
	print("\n=== CONTACT QUALITY PROPERTY TEST ===\n")
	print("Property 2: Contact quality determines ball behavior consistently")
	print("Generating " + str(NUM_RANDOM_TESTS) + " random test cases...\n")
	
	# Initialize calculator
	calculator = ContactQualityCalculator.new()
	
	# Run property tests
	_run_property_tests()
	
	# Print results
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Run property-based tests
func _run_property_tests() -> void:
	# Property: Contact quality assignment is consistent across all timing offsets
	test_property_quality_consistency()
	
	# Property: Quality multipliers are deterministic
	test_property_multiplier_determinism()
	
	# Property: Power threshold is strictly enforced
	test_property_power_threshold_enforcement()
	
	# Property: Timing windows are mutually exclusive and complete
	test_property_window_coverage()


## Property Test: Quality assignment is consistent for same inputs
func test_property_quality_consistency() -> void:
	print("Property Test: Quality assignment consistency")
	
	var failed_cases: Array[String] = []
	
	for i in range(NUM_RANDOM_TESTS):
		# Generate random power (20% to 100%)
		var power = randf_range(0.2, 1.0)
		
		# Generate random timing offset (-0.5s to +0.5s)
		var timing_offset = randf_range(-0.5, 0.5)
		
		# Calculate quality twice
		var quality1 = calculator.calculate_quality(power, timing_offset)
		var quality2 = calculator.calculate_quality(power, timing_offset)
		
		# Verify consistency
		if quality1 != quality2:
			var case = "Inconsistent quality for power=" + str(power) + ", offset=" + str(timing_offset)
			failed_cases.append(case)
	
	if failed_cases.is_empty():
		_pass_test("Quality assignment is consistent (100/" + str(NUM_RANDOM_TESTS) + " random cases)")
	else:
		_fail_test("Quality assignment inconsistent: " + str(failed_cases.size()) + " cases failed")
		for case in failed_cases:
			print("    " + case)


## Property Test: Multipliers are deterministic for each quality level
func test_property_multiplier_determinism() -> void:
	print("\nProperty Test: Multiplier determinism")
	
	# Test each quality level multiple times
	var qualities = [
		StrikeData.ContactQuality.PERFECT,
		StrikeData.ContactQuality.CLEAN,
		StrikeData.ContactQuality.OKAY,
		StrikeData.ContactQuality.SCUFFED
	]
	
	var expected_multipliers = {
		StrikeData.ContactQuality.PERFECT: 1.25,
		StrikeData.ContactQuality.CLEAN: 1.0,
		StrikeData.ContactQuality.OKAY: 0.85,
		StrikeData.ContactQuality.SCUFFED: 0.7
	}
	
	var all_consistent = true
	
	for quality in qualities:
		var expected = expected_multipliers[quality]
		
		# Call multiple times
		for i in range(10):
			var multiplier = calculator.get_quality_multiplier(quality)
			if abs(multiplier - expected) > EPSILON:
				_fail_test("Multiplier for " + _quality_to_string(quality) + " not deterministic")
				all_consistent = false
				break
		
		if not all_consistent:
			break
	
	if all_consistent:
		_pass_test("All quality multipliers are deterministic")


## Property Test: Power threshold is strictly enforced
func test_property_power_threshold_enforcement() -> void:
	print("\nProperty Test: Power threshold enforcement")
	
	var failed_cases: Array[String] = []
	
	for i in range(NUM_RANDOM_TESTS):
		# Generate random power below threshold (0% to 19.9%)
		var power = randf_range(0.0, 0.199)
		
		# Generate random timing offset (should not matter)
		var timing_offset = randf_range(-0.5, 0.5)
		
		# Should always return SCUFFED for low power
		var quality = calculator.calculate_quality(power, timing_offset)
		
		if quality != StrikeData.ContactQuality.SCUFFED:
			var case = "Power " + str(power) + " should be SCUFFED, got " + _quality_to_string(quality)
			failed_cases.append(case)
	
	if failed_cases.is_empty():
		_pass_test("Power threshold strictly enforced (100/" + str(NUM_RANDOM_TESTS) + " cases)")
	else:
		_fail_test("Power threshold violations: " + str(failed_cases.size()) + " cases")
		for case in failed_cases.slice(0, 5):  # Show first 5 failures
			print("    " + case)


## Property Test: Timing windows are mutually exclusive and complete
func test_property_window_coverage() -> void:
	print("\nProperty Test: Timing window coverage (mutually exclusive and complete)")
	
	var failed_cases: Array[String] = []
	var quality_counts = {
		StrikeData.ContactQuality.PERFECT: 0,
		StrikeData.ContactQuality.CLEAN: 0,
		StrikeData.ContactQuality.OKAY: 0,
		StrikeData.ContactQuality.SCUFFED: 0
	}
	
	# Test a wide range of timing offsets
	for i in range(NUM_RANDOM_TESTS * 2):  # More tests for coverage
		# Generate random power (90%+ for PERFECT eligibility)
		var power = randf_range(0.9, 1.0)
		
		# Generate random timing offset (-1.0s to +1.0s)
		var timing_offset = randf_range(-1.0, 1.0)
		
		# Calculate quality
		var quality = calculator.calculate_quality(power, timing_offset)
		quality_counts[quality] += 1
		
		# Verify quality matches expected window
		var abs_offset = abs(timing_offset)
		var expected_quality: StrikeData.ContactQuality
		
		if abs_offset <= 0.05:
			expected_quality = StrikeData.ContactQuality.PERFECT
		elif abs_offset <= 0.15:
			expected_quality = StrikeData.ContactQuality.CLEAN
		elif abs_offset <= 0.30:
			expected_quality = StrikeData.ContactQuality.OKAY
		else:
			expected_quality = StrikeData.ContactQuality.SCUFFED
		
		if quality != expected_quality:
			var case = "Offset " + str(timing_offset) + " expected " + _quality_to_string(expected_quality) + ", got " + _quality_to_string(quality)
			failed_cases.append(case)
	
	# Verify all qualities were encountered (coverage)
	var all_qualities_covered = true
	for quality in quality_counts:
		if quality_counts[quality] == 0:
			all_qualities_covered = false
			print("  WARNING: Quality " + _quality_to_string(quality) + " not encountered in random tests")
	
	if failed_cases.is_empty():
		_pass_test("Timing windows are mutually exclusive and complete (200/" + str(NUM_RANDOM_TESTS * 2) + " cases)")
		print("  Quality distribution:")
		for quality in quality_counts:
			print("    " + _quality_to_string(quality) + ": " + str(quality_counts[quality]) + " cases")
	else:
		_fail_test("Window coverage violations: " + str(failed_cases.size()) + " cases")
		for case in failed_cases.slice(0, 5):  # Show first 5 failures
			print("    " + case)


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
	print("\n=== PROPERTY TEST RESULTS ===")
	print("Passed: " + str(tests_passed))
	print("Failed: " + str(tests_failed))
	print("Total:  " + str(tests_passed + tests_failed))
	print("Random test cases generated: " + str(NUM_RANDOM_TESTS))
	
	if tests_failed > 0:
		print("\nFailed tests:")
		for result in test_results:
			if result.begins_with("✗"):
				print("  " + result)
	
	if tests_failed == 0:
		print("\n🎯 ALL PROPERTY TESTS PASSED!")
	else:
		print("\n❌ SOME PROPERTY TESTS FAILED")
