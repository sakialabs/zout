extends Node3D

## Strike Flow Validation Script
## Task 11: Checkpoint - Core mechanics validation
## Tests complete strike flow: aim → charge → contact → flight → outcome

var validation_results: Dictionary = {}
var all_tests_passed: bool = true

# Scene references
@onready var ball: BallPhysics = $Ball
@onready var goal_detector: GoalDetector = $GoalDetector
@onready var strike_controller: StrikeController = $StrikeController

# Test state tracking
var current_test: String = ""
var test_complete: bool = false
var goal_detected: bool = false
var goal_is_top_bins: bool = false
var goal_entry_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	print("\n=== STRIKE FLOW VALIDATION ===\n")
	
	# Set up scene references
	setup_scene()
	
	# Connect signals
	if goal_detector:
		goal_detector.goal_scored.connect(_on_goal_scored)
		goal_detector.ball_missed.connect(_on_ball_missed)
	
	if strike_controller:
		strike_controller.strike_executed.connect(_on_strike_executed)
		strike_controller.state_changed.connect(_on_state_changed)
	
	# Run validation tests
	await run_all_tests()
	
	# Print summary
	print_summary()
	
	# Exit after validation
	get_tree().quit()


## Set up scene references
func setup_scene() -> void:
	# Ensure ball has BallPhysics script
	if ball and not ball.has_method("apply_strike"):
		print("⚠️  Ball missing BallPhysics script - adding it")
		var script = load("res://scripts/ball_physics.gd")
		ball.set_script(script)
	
	# Ensure goal detector is set up
	if not goal_detector:
		print("⚠️  GoalDetector not found in scene")
	
	# Ensure strike controller is set up
	if not strike_controller:
		print("⚠️  StrikeController not found in scene")
	
	# Link strike controller to ball and goal
	if strike_controller:
		strike_controller.ball_physics = ball
		strike_controller.goal_detector = goal_detector


## Run all validation tests
func run_all_tests() -> void:
	await test_complete_strike_flow()
	await test_contact_quality_affects_physics()
	await test_goal_detection()
	await test_top_bins_detection()
	await test_state_transitions()


## Test 1: Complete strike flow (aim → charge → contact → flight → outcome)
func test_complete_strike_flow() -> void:
	print("Test 1: Complete Strike Flow")
	current_test = "complete_flow"
	var passed = true
	
	# Reset scene
	reset_test_scene()
	
	# Verify initial state
	if strike_controller.current_state != StrikeController.StrikeState.READY:
		print("  ❌ Initial state not READY")
		passed = false
	else:
		print("  ✓ Initial state is READY")
	
	# Simulate aim input
	strike_controller.aim_input = Vector2(0.0, 0.0)  # Aim at goal center
	await get_tree().create_timer(0.1).timeout
	
	if strike_controller.current_state != StrikeController.StrikeState.AIMING:
		print("  ❌ State didn't transition to AIMING")
		passed = false
	else:
		print("  ✓ Transitioned to AIMING state")
	
	# Simulate power charge
	strike_controller.is_power_button_held = true
	strike_controller.power_system.start_charge()
	await get_tree().create_timer(0.1).timeout
	
	if strike_controller.current_state != StrikeController.StrikeState.CHARGING:
		print("  ❌ State didn't transition to CHARGING")
		passed = false
	else:
		print("  ✓ Transitioned to CHARGING state")
	
	# Wait for optimal power (95% = 1.425s)
	await get_tree().create_timer(1.35).timeout
	
	# Release power
	strike_controller.is_power_button_held = false
	strike_controller.release_time = Time.get_ticks_msec() / 1000.0
	await get_tree().create_timer(0.1).timeout
	
	# Should be in FLIGHT state now
	if strike_controller.current_state != StrikeController.StrikeState.FLIGHT:
		print("  ❌ State didn't transition to FLIGHT (current: ", strike_controller.current_state, ")")
		passed = false
	else:
		print("  ✓ Transitioned to FLIGHT state")
	
	# Check ball is moving
	await get_tree().create_timer(0.2).timeout
	if ball.linear_velocity.length() < 1.0:
		print("  ❌ Ball not moving after strike (velocity: ", ball.linear_velocity.length(), ")")
		passed = false
	else:
		print("  ✓ Ball is moving after strike")
	
	# Wait for outcome (goal or miss)
	var timeout = 5.0
	var elapsed = 0.0
	while not test_complete and elapsed < timeout:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1
	
	if not test_complete:
		print("  ❌ No outcome detected within timeout")
		passed = false
	elif strike_controller.current_state != StrikeController.StrikeState.OUTCOME:
		print("  ❌ State didn't transition to OUTCOME")
		passed = false
	else:
		print("  ✓ Transitioned to OUTCOME state")
	
	validation_results["Complete Strike Flow"] = passed
	if not passed:
		all_tests_passed = false
	
	test_complete = false


## Test 2: Contact quality affects ball physics
func test_contact_quality_affects_physics() -> void:
	print("\nTest 2: Contact Quality Affects Physics")
	current_test = "quality_physics"
	var passed = true
	
	# Test different quality levels and measure drift
	var qualities = [
		StrikeData.ContactQuality.PERFECT,
		StrikeData.ContactQuality.CLEAN,
		StrikeData.ContactQuality.OKAY,
		StrikeData.ContactQuality.SCUFFED
	]
	
	var quality_names = ["PERFECT", "CLEAN", "OKAY", "SCUFFED"]
	var expected_drifts = [0.0, 2.0, 5.0, 10.0]
	
	for i in range(qualities.size()):
		reset_test_scene()
		
		var quality = qualities[i]
		var quality_name = quality_names[i]
		var expected_drift = expected_drifts[i]
		
		# Apply strike with specific quality
		var aim_direction = Vector3.FORWARD
		var power = 0.8
		ball.apply_strike(aim_direction, power, quality)
		
		# Wait for ball to travel
		await get_tree().create_timer(0.5).timeout
		
		# Measure actual trajectory vs intended
		var actual_direction = ball.linear_velocity.normalized()
		var angle_diff = rad_to_deg(aim_direction.angle_to(actual_direction))
		
		# Check if drift is within expected bounds
		if quality == StrikeData.ContactQuality.PERFECT:
			if angle_diff > 0.5:  # Very small tolerance for perfect
				print("  ❌ ", quality_name, " quality has too much drift (", angle_diff, "°)")
				passed = false
			else:
				print("  ✓ ", quality_name, " quality has minimal drift (", angle_diff, "°)")
		else:
			if angle_diff > expected_drift + 1.0:  # Allow some tolerance
				print("  ❌ ", quality_name, " quality drift exceeds maximum (", angle_diff, "° > ", expected_drift, "°)")
				passed = false
			else:
				print("  ✓ ", quality_name, " quality drift within bounds (", angle_diff, "° ≤ ", expected_drift, "°)")
	
	validation_results["Contact Quality Physics"] = passed
	if not passed:
		all_tests_passed = false


## Test 3: Goal detection works correctly
func test_goal_detection() -> void:
	print("\nTest 3: Goal Detection")
	current_test = "goal_detection"
	var passed = true
	
	# Test 1: Ball crossing goal line should trigger goal
	reset_test_scene()
	goal_detected = false
	
	# Position ball just before goal line and give it velocity toward goal
	ball.global_position = Vector3(0, 1.22, 39.5)  # Just before goal
	ball.linear_velocity = Vector3(0, 0, 5)  # Moving toward goal
	
	# Wait for goal detection
	await get_tree().create_timer(0.5).timeout
	
	if not goal_detected:
		print("  ❌ Goal not detected when ball crosses goal line")
		passed = false
	else:
		print("  ✓ Goal detected when ball crosses goal line")
	
	# Test 2: Ball outside goal boundaries should not trigger goal
	reset_test_scene()
	goal_detected = false
	
	# Position ball outside goal width
	ball.global_position = Vector3(5.0, 1.22, 39.5)  # Outside goal width (7.32m / 2 = 3.66m)
	ball.linear_velocity = Vector3(0, 0, 5)
	
	await get_tree().create_timer(0.5).timeout
	
	if goal_detected:
		print("  ❌ Goal detected when ball is outside goal boundaries")
		passed = false
	else:
		print("  ✓ Goal not detected when ball is outside boundaries")
	
	# Test 3: Ball above goal height should not trigger goal
	reset_test_scene()
	goal_detected = false
	
	# Position ball above goal height
	ball.global_position = Vector3(0, 3.0, 39.5)  # Above goal height (2.44m)
	ball.linear_velocity = Vector3(0, 0, 5)
	
	await get_tree().create_timer(0.5).timeout
	
	if goal_detected:
		print("  ❌ Goal detected when ball is above goal height")
		passed = false
	else:
		print("  ✓ Goal not detected when ball is above goal height")
	
	validation_results["Goal Detection"] = passed
	if not passed:
		all_tests_passed = false


## Test 4: Top Bins detection
func test_top_bins_detection() -> void:
	print("\nTest 4: Top Bins Detection")
	current_test = "top_bins"
	var passed = true
	
	# Test 1: Top left corner should trigger Top Bins
	reset_test_scene()
	goal_detected = false
	goal_is_top_bins = false
	
	# Position in top left corner (upper 25% height, outer 30% width)
	# Height: 1.83m - 2.44m, Width left: 0 - 2.196m from center
	ball.global_position = Vector3(-2.0, 2.0, 39.5)
	ball.linear_velocity = Vector3(0, 0, 5)
	
	await get_tree().create_timer(0.5).timeout
	
	if not goal_detected:
		print("  ❌ Goal not detected in top corner")
		passed = false
	elif not goal_is_top_bins:
		print("  ❌ Top Bins not detected in top left corner")
		passed = false
	else:
		print("  ✓ Top Bins detected in top left corner")
	
	# Test 2: Top right corner should trigger Top Bins
	reset_test_scene()
	goal_detected = false
	goal_is_top_bins = false
	
	ball.global_position = Vector3(2.0, 2.0, 39.5)
	ball.linear_velocity = Vector3(0, 0, 5)
	
	await get_tree().create_timer(0.5).timeout
	
	if not goal_detected:
		print("  ❌ Goal not detected in top corner")
		passed = false
	elif not goal_is_top_bins:
		print("  ❌ Top Bins not detected in top right corner")
		passed = false
	else:
		print("  ✓ Top Bins detected in top right corner")
	
	# Test 3: Center of goal should NOT trigger Top Bins
	reset_test_scene()
	goal_detected = false
	goal_is_top_bins = false
	
	ball.global_position = Vector3(0, 1.22, 39.5)  # Center of goal
	ball.linear_velocity = Vector3(0, 0, 5)
	
	await get_tree().create_timer(0.5).timeout
	
	if not goal_detected:
		print("  ❌ Goal not detected in center")
		passed = false
	elif goal_is_top_bins:
		print("  ❌ Top Bins incorrectly detected in center")
		passed = false
	else:
		print("  ✓ Top Bins not detected in center (correct)")
	
	# Test 4: Bottom corner should NOT trigger Top Bins
	reset_test_scene()
	goal_detected = false
	goal_is_top_bins = false
	
	ball.global_position = Vector3(-2.0, 0.5, 39.5)  # Bottom left
	ball.linear_velocity = Vector3(0, 0, 5)
	
	await get_tree().create_timer(0.5).timeout
	
	if not goal_detected:
		print("  ❌ Goal not detected in bottom corner")
		passed = false
	elif goal_is_top_bins:
		print("  ❌ Top Bins incorrectly detected in bottom corner")
		passed = false
	else:
		print("  ✓ Top Bins not detected in bottom corner (correct)")
	
	validation_results["Top Bins Detection"] = passed
	if not passed:
		all_tests_passed = false


## Test 5: State transitions work correctly
func test_state_transitions() -> void:
	print("\nTest 5: State Transitions")
	current_test = "state_transitions"
	var passed = true
	
	# Test reset from various states
	reset_test_scene()
	
	# From AIMING state
	strike_controller.change_state(StrikeController.StrikeState.AIMING)
	strike_controller.reset_strike()
	await get_tree().create_timer(0.1).timeout
	
	if strike_controller.current_state != StrikeController.StrikeState.READY:
		print("  ❌ Reset from AIMING didn't return to READY")
		passed = false
	else:
		print("  ✓ Reset from AIMING returns to READY")
	
	# From CHARGING state
	strike_controller.change_state(StrikeController.StrikeState.CHARGING)
	strike_controller.reset_strike()
	await get_tree().create_timer(0.1).timeout
	
	if strike_controller.current_state != StrikeController.StrikeState.READY:
		print("  ❌ Reset from CHARGING didn't return to READY")
		passed = false
	else:
		print("  ✓ Reset from CHARGING returns to READY")
	
	# From FLIGHT state
	strike_controller.change_state(StrikeController.StrikeState.FLIGHT)
	strike_controller.reset_strike()
	await get_tree().create_timer(0.1).timeout
	
	if strike_controller.current_state != StrikeController.StrikeState.READY:
		print("  ❌ Reset from FLIGHT didn't return to READY")
		passed = false
	else:
		print("  ✓ Reset from FLIGHT returns to READY")
	
	validation_results["State Transitions"] = passed
	if not passed:
		all_tests_passed = false


## Reset test scene to initial state
func reset_test_scene() -> void:
	if ball:
		ball.global_position = Vector3(0, 0.5, -20)
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO
	
	if strike_controller:
		strike_controller.change_state(StrikeController.StrikeState.READY)
		strike_controller.aim_input = Vector2.ZERO
		strike_controller.power_level = 0.0
		strike_controller.is_power_button_held = false
	
	goal_detected = false
	goal_is_top_bins = false
	test_complete = false


## Signal handlers
func _on_goal_scored(entry_position: Vector3, is_top_bins: bool) -> void:
	goal_detected = true
	goal_is_top_bins = is_top_bins
	goal_entry_position = entry_position
	test_complete = true


func _on_ball_missed() -> void:
	goal_detected = false
	test_complete = true


func _on_strike_executed(power: float, direction: Vector3, quality: StrikeData.ContactQuality) -> void:
	pass  # Track if needed


func _on_state_changed(old_state: StrikeController.StrikeState, new_state: StrikeController.StrikeState) -> void:
	pass  # Track if needed


## Print validation summary
func print_summary() -> void:
	print("\n=== VALIDATION SUMMARY ===\n")
	
	for test_name in validation_results:
		var status = "✓ PASSED" if validation_results[test_name] else "❌ FAILED"
		print(test_name, ": ", status)
	
	print("\n")
	if all_tests_passed:
		print("🎉 ALL STRIKE FLOW TESTS PASSED!")
		print("\n✅ Core mechanics validated:")
		print("  • Complete strike flow works (aim → charge → contact → flight → outcome)")
		print("  • Ball physics responds correctly to contact quality")
		print("  • Goal detection works accurately")
		print("  • Top Bins detection works correctly")
		print("  • State transitions function properly")
	else:
		print("⚠️  SOME TESTS FAILED - SEE DETAILS ABOVE")
	
	print("\n==============================\n")
