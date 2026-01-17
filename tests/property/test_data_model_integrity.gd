extends Node

## Property-based test for data model integrity
## Property 1: Strike execution preserves input parameters
## Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5
## Feature: practice-mode-mvp, Property 1: Strike execution preserves input parameters

# Preload required classes
const StrikeData = preload("res://scripts/strike_data.gd")

# Test configuration
const NUM_ITERATIONS: int = 100  # Minimum 100 iterations for property tests
const EPSILON: float = 0.0001  # Floating point comparison tolerance

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []
var failed_cases: Array[Dictionary] = []


func _ready() -> void:
	print("\n=== DATA MODEL INTEGRITY PROPERTY TEST ===")
	print("Property 1: Strike execution preserves input parameters")
	print("Running " + str(NUM_ITERATIONS) + " iterations with random inputs\n")
	
	# Seed random for reproducibility (can be changed for different test runs)
	var test_seed = Time.get_ticks_msec()
	seed(test_seed)
	print("Random seed: " + str(test_seed) + "\n")
	
	# Run property test
	_run_property_test()
	
	# Print results
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Run property-based test with random inputs
func _run_property_test() -> void:
	print("Running property test iterations...")
	
	for i in range(NUM_ITERATIONS):
		# Generate random strike parameters
		var random_aim = _generate_random_aim_direction()
		var random_power = _generate_random_power()
		var random_timing = _generate_random_timing()
		var random_quality = _generate_random_quality()
		
		# Create StrikeData with random parameters
		var strike_data = StrikeData.new(
			random_aim,
			random_power,
			random_timing,
			random_quality
		)
		
		# Verify that StrikeData preserves the exact input parameters
		var aim_preserved = _vectors_equal(strike_data.aim_direction, random_aim)
		var power_preserved = _floats_equal(strike_data.power_level, random_power)
		var timing_preserved = _floats_equal(strike_data.timing_offset, random_timing)
		var quality_preserved = (strike_data.contact_quality == random_quality)
		var timestamp_valid = strike_data.timestamp > 0.0
		
		# Check if all parameters are preserved
		if aim_preserved and power_preserved and timing_preserved and quality_preserved and timestamp_valid:
			tests_passed += 1
		else:
			tests_failed += 1
			
			# Record failure details
			var failure_info = {
				"iteration": i + 1,
				"input_aim": random_aim,
				"stored_aim": strike_data.aim_direction,
				"aim_match": aim_preserved,
				"input_power": random_power,
				"stored_power": strike_data.power_level,
				"power_match": power_preserved,
				"input_timing": random_timing,
				"stored_timing": strike_data.timing_offset,
				"timing_match": timing_preserved,
				"input_quality": random_quality,
				"stored_quality": strike_data.contact_quality,
				"quality_match": quality_preserved,
				"timestamp_valid": timestamp_valid
			}
			failed_cases.append(failure_info)
			
			# Print first few failures for debugging
			if tests_failed <= 3:
				print("\n✗ Iteration " + str(i + 1) + " FAILED:")
				if not aim_preserved:
					print("  Aim mismatch: input=" + str(random_aim) + ", stored=" + str(strike_data.aim_direction))
				if not power_preserved:
					print("  Power mismatch: input=" + str(random_power) + ", stored=" + str(strike_data.power_level))
				if not timing_preserved:
					print("  Timing mismatch: input=" + str(random_timing) + ", stored=" + str(strike_data.timing_offset))
				if not quality_preserved:
					print("  Quality mismatch: input=" + str(random_quality) + ", stored=" + str(strike_data.contact_quality))
				if not timestamp_valid:
					print("  Invalid timestamp: " + str(strike_data.timestamp))
	
	print("\nCompleted " + str(NUM_ITERATIONS) + " iterations")


## Generate random aim direction (normalized Vector3)
func _generate_random_aim_direction() -> Vector3:
	# Generate random direction within aim cone constraints
	# Horizontal: ±45° from center, Vertical: ±30° from center
	var horizontal_angle = randf_range(-45.0, 45.0)
	var vertical_angle = randf_range(-30.0, 30.0)
	
	# Convert to radians
	var h_rad = deg_to_rad(horizontal_angle)
	var v_rad = deg_to_rad(vertical_angle)
	
	# Create direction vector (assuming forward is +Z)
	var direction = Vector3(
		sin(h_rad),
		sin(v_rad),
		cos(h_rad) * cos(v_rad)
	)
	
	return direction.normalized()


## Generate random power level (20% to 100%)
func _generate_random_power() -> float:
	# Power range: 0.2 to 1.0 (20% to 100%)
	return randf_range(0.2, 1.0)


## Generate random timing offset
func _generate_random_timing() -> float:
	# Timing offset range: -0.5 to +0.5 seconds
	return randf_range(-0.5, 0.5)


## Generate random contact quality
func _generate_random_quality() -> StrikeData.ContactQuality:
	var qualities = [
		StrikeData.ContactQuality.PERFECT,
		StrikeData.ContactQuality.CLEAN,
		StrikeData.ContactQuality.OKAY,
		StrikeData.ContactQuality.SCUFFED
	]
	return qualities[randi() % qualities.size()]


## Compare two Vector3 values with epsilon tolerance
func _vectors_equal(a: Vector3, b: Vector3) -> bool:
	return (
		absf(a.x - b.x) < EPSILON and
		absf(a.y - b.y) < EPSILON and
		absf(a.z - b.z) < EPSILON
	)


## Compare two float values with epsilon tolerance
func _floats_equal(a: float, b: float) -> bool:
	return absf(a - b) < EPSILON


## Print test results summary
func _print_results() -> void:
	print("\n=== TEST RESULTS ===")
	print("Total iterations: " + str(NUM_ITERATIONS))
	print("Passed: " + str(tests_passed))
	print("Failed: " + str(tests_failed))
	print("Success rate: " + str(snappedf((float(tests_passed) / float(NUM_ITERATIONS)) * 100.0, 0.01)) + "%")
	
	if tests_failed == 0:
		print("\n✓ PROPERTY TEST PASSED")
		print("All " + str(NUM_ITERATIONS) + " random inputs were preserved exactly in StrikeData")
	else:
		print("\n✗ PROPERTY TEST FAILED")
		print(str(tests_failed) + " out of " + str(NUM_ITERATIONS) + " iterations failed")
		
		if failed_cases.size() > 0:
			print("\nFirst failure details:")
			var first_failure = failed_cases[0]
			print("  Iteration: " + str(first_failure["iteration"]))
			print("  Input aim: " + str(first_failure["input_aim"]))
			print("  Stored aim: " + str(first_failure["stored_aim"]))
			print("  Aim match: " + str(first_failure["aim_match"]))
			print("  Input power: " + str(first_failure["input_power"]))
			print("  Stored power: " + str(first_failure["stored_power"]))
			print("  Power match: " + str(first_failure["power_match"]))
			print("  Input timing: " + str(first_failure["input_timing"]))
			print("  Stored timing: " + str(first_failure["stored_timing"]))
			print("  Timing match: " + str(first_failure["timing_match"]))
			print("  Input quality: " + str(first_failure["input_quality"]))
			print("  Stored quality: " + str(first_failure["stored_quality"]))
			print("  Quality match: " + str(first_failure["quality_match"]))
