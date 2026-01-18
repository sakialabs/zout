extends Node

## Unit tests for AimSystem clamping behavior
## Tests aim stays within cone bounds
## Tests extreme input values
## Tests zero vector defaults to goal center
## Validates: Requirements 1.1

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []

# System under test
var aim_system: AimSystem

# Test configuration
const EPSILON = 0.001  # Floating point comparison tolerance


func _ready() -> void:
	print("\n=== AIM CLAMPING UNIT TESTS ===\n")
	
	# Initialize aim system
	aim_system = AimSystem.new()
	
	# Run tests
	_run_all_tests()
	
	# Print results
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Run all unit tests
func _run_all_tests() -> void:
	# Zero vector tests
	test_zero_vector_defaults_to_goal_center()
	
	# Normalized input tests
	test_normalized_input_within_bounds()
	test_center_aim_is_forward()
	test_maximum_left_aim()
	test_maximum_right_aim()
	test_maximum_up_aim()
	test_maximum_down_aim()
	
	# Extreme input clamping tests
	test_extreme_input_clamped_horizontal()
	test_extreme_input_clamped_vertical()
	test_extreme_input_clamped_diagonal()
	
	# Cone angle validation tests
	test_horizontal_cone_angle_45_degrees()
	test_vertical_cone_angle_30_degrees()
	
	# Input validation tests
	test_update_aim_clamps_to_normalized()
	test_nan_protection()


## Test: Zero vector defaults to goal center
func test_zero_vector_defaults_to_goal_center() -> void:
	var test_name = "Zero vector defaults to goal center"
	
	# Set aim to zero
	aim_system.update_aim(Vector2.ZERO)
	var direction = aim_system.get_aim_direction()
	
	# Should return forward direction (goal center)
	var expected = Vector3.FORWARD.normalized()
	
	if _vectors_equal(direction, expected):
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(direction) + ", Expected: " + str(expected))


## Test: Normalized input stays within bounds
func test_normalized_input_within_bounds() -> void:
	var test_name = "Normalized input within bounds (0.5, 0.5)"
	
	aim_system.update_aim(Vector2(0.5, 0.5))
	var direction = aim_system.get_aim_direction()
	
	# Direction should be normalized
	if abs(direction.length() - 1.0) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Direction not normalized: " + str(direction.length()))


## Test: Center aim is forward
func test_center_aim_is_forward() -> void:
	var test_name = "Center aim (0, 0) is forward"
	
	aim_system.update_aim(Vector2(0.0, 0.0))
	var direction = aim_system.get_aim_direction()
	
	var expected = Vector3.FORWARD.normalized()
	
	if _vectors_equal(direction, expected):
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(direction))


## Test: Maximum left aim (-1, 0)
func test_maximum_left_aim() -> void:
	var test_name = "Maximum left aim (-1, 0)"
	
	aim_system.update_aim(Vector2(-1.0, 0.0))
	var direction = aim_system.get_aim_direction()
	
	# Calculate expected angle (45° left from forward)
	var expected_horizontal_angle = -deg_to_rad(45.0)
	var expected_direction = Vector3.FORWARD.rotated(Vector3.UP, expected_horizontal_angle)
	
	if _vectors_equal(direction, expected_direction):
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(direction) + ", Expected: " + str(expected_direction))


## Test: Maximum right aim (+1, 0)
func test_maximum_right_aim() -> void:
	var test_name = "Maximum right aim (+1, 0)"
	
	aim_system.update_aim(Vector2(1.0, 0.0))
	var direction = aim_system.get_aim_direction()
	
	# Calculate expected angle (45° right from forward)
	var expected_horizontal_angle = deg_to_rad(45.0)
	var expected_direction = Vector3.FORWARD.rotated(Vector3.UP, expected_horizontal_angle)
	
	if _vectors_equal(direction, expected_direction):
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Got: " + str(direction) + ", Expected: " + str(expected_direction))


## Test: Maximum up aim (0, +1)
func test_maximum_up_aim() -> void:
	var test_name = "Maximum up aim (0, +1)"
	
	aim_system.update_aim(Vector2(0.0, 1.0))
	var direction = aim_system.get_aim_direction()
	
	# Should aim upward at 30° vertical angle
	# Y component should be positive
	if direction.y > 0.4:  # sin(30°) ≈ 0.5
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Y component too low: " + str(direction.y))


## Test: Maximum down aim (0, -1)
func test_maximum_down_aim() -> void:
	var test_name = "Maximum down aim (0, -1)"
	
	aim_system.update_aim(Vector2(0.0, -1.0))
	var direction = aim_system.get_aim_direction()
	
	# Should aim downward at 30° vertical angle
	# Y component should be negative
	if direction.y < -0.4:  # -sin(30°) ≈ -0.5
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Y component not low enough: " + str(direction.y))


## Test: Extreme input clamped (horizontal)
func test_extreme_input_clamped_horizontal() -> void:
	var test_name = "Extreme input clamped horizontal (10, 0)"
	
	aim_system.update_aim(Vector2(10.0, 0.0))
	
	# Current aim should be clamped to 1.0
	if abs(aim_system.current_aim.x - 1.0) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Not clamped: " + str(aim_system.current_aim.x))


## Test: Extreme input clamped (vertical)
func test_extreme_input_clamped_vertical() -> void:
	var test_name = "Extreme input clamped vertical (0, -10)"
	
	aim_system.update_aim(Vector2(0.0, -10.0))
	
	# Current aim should be clamped to -1.0
	if abs(aim_system.current_aim.y - (-1.0)) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Not clamped: " + str(aim_system.current_aim.y))


## Test: Extreme input clamped (diagonal)
func test_extreme_input_clamped_diagonal() -> void:
	var test_name = "Extreme input clamped diagonal (100, 100)"
	
	aim_system.update_aim(Vector2(100.0, 100.0))
	
	# Both components should be clamped to 1.0
	if abs(aim_system.current_aim.x - 1.0) < EPSILON and abs(aim_system.current_aim.y - 1.0) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Not clamped: " + str(aim_system.current_aim))


## Test: Horizontal cone angle is 45 degrees
func test_horizontal_cone_angle_45_degrees() -> void:
	var test_name = "Horizontal cone angle is 45 degrees"
	
	# Aim fully to the right
	aim_system.update_aim(Vector2(1.0, 0.0))
	var direction = aim_system.get_aim_direction()
	
	# Calculate actual angle from forward
	var forward = Vector3.FORWARD
	var angle_rad = acos(forward.dot(direction))
	var angle_deg = rad_to_deg(angle_rad)
	
	# Should be 45 degrees
	if abs(angle_deg - 45.0) < 1.0:  # Allow 1 degree tolerance
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Angle: " + str(angle_deg) + "°, Expected: 45°")


## Test: Vertical cone angle is 30 degrees
func test_vertical_cone_angle_30_degrees() -> void:
	var test_name = "Vertical cone angle is 30 degrees"
	
	# Aim fully upward
	aim_system.update_aim(Vector2(0.0, 1.0))
	var direction = aim_system.get_aim_direction()
	
	# Calculate vertical angle
	var horizontal_plane = Vector3(direction.x, 0, direction.z).normalized()
	var angle_rad = acos(horizontal_plane.dot(direction))
	var angle_deg = rad_to_deg(angle_rad)
	
	# Should be 30 degrees
	if abs(angle_deg - 30.0) < 1.0:  # Allow 1 degree tolerance
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Angle: " + str(angle_deg) + "°, Expected: 30°")


## Test: update_aim clamps to normalized range
func test_update_aim_clamps_to_normalized() -> void:
	var test_name = "update_aim clamps to normalized range"
	
	# Test multiple extreme values
	var extreme_values = [
		Vector2(5.0, 0.0),
		Vector2(-5.0, 0.0),
		Vector2(0.0, 5.0),
		Vector2(0.0, -5.0),
		Vector2(10.0, 10.0),
		Vector2(-10.0, -10.0)
	]
	
	var all_clamped = true
	
	for value in extreme_values:
		aim_system.update_aim(value)
		
		# Check if clamped to -1.0 to 1.0 range
		if aim_system.current_aim.x < -1.0 or aim_system.current_aim.x > 1.0:
			all_clamped = false
			break
		if aim_system.current_aim.y < -1.0 or aim_system.current_aim.y > 1.0:
			all_clamped = false
			break
	
	if all_clamped:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Some values not clamped")


## Test: NaN protection
func test_nan_protection() -> void:
	var test_name = "NaN protection and invalid direction handling"
	
	# This is more of a robustness test
	# Try very small aim values that might cause issues
	aim_system.update_aim(Vector2(0.00001, 0.00001))
	var direction = aim_system.get_aim_direction()
	
	# Direction should still be valid and normalized
	if not direction.is_nan() and abs(direction.length() - 1.0) < EPSILON:
		_pass_test(test_name)
	else:
		_fail_test(test_name + " - Direction invalid: " + str(direction))


## Helper: Compare two Vector3 with epsilon tolerance
func _vectors_equal(a: Vector3, b: Vector3) -> bool:
	return a.distance_to(b) < EPSILON


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
