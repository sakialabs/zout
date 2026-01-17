extends Node

## Unit tests for scene initialization
## Tests scene loads within 3 seconds
## Tests all required nodes exist in scene tree
## Validates: Requirements 11.5

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []

# Scene reference
var practice_scene: PackedScene


func _ready() -> void:
	print("\n=== SCENE INITIALIZATION UNIT TESTS ===\n")
	
	# Run tests
	await _run_all_tests()
	
	# Print results
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Run all unit tests
func _run_all_tests() -> void:
	await test_scene_loads_within_3_seconds()
	await test_all_required_nodes_exist()


## Test 1: Scene loads within 3 seconds
## Validates: Requirements 11.5
func test_scene_loads_within_3_seconds() -> void:
	var test_name = "Test 1: Scene loads within 3 seconds"
	print("Running: " + test_name)
	
	# Load the practice mode scene
	practice_scene = load("res://scenes/practice_mode.tscn")
	
	# Measure instantiation time
	var start_time = Time.get_ticks_msec()
	var scene_instance = practice_scene.instantiate()
	var load_time_ms = Time.get_ticks_msec() - start_time
	var load_time_sec = load_time_ms / 1000.0
	
	# Add to tree to ensure full initialization
	add_child(scene_instance)
	await get_tree().process_frame
	
	# Check if load time is under 3 seconds
	var loads_fast_enough = load_time_sec < 3.0
	
	if loads_fast_enough:
		_pass_test(test_name)
		print("  ✓ Scene loaded in " + str(snappedf(load_time_sec, 0.001)) + "s (< 3.0s)")
	else:
		_fail_test(test_name)
		print("  ✗ Scene took " + str(snappedf(load_time_sec, 0.001)) + "s to load (should be < 3.0s)")
	
	# Clean up
	scene_instance.queue_free()
	await get_tree().process_frame


## Test 2: All required nodes exist in scene tree
## Validates: Requirements 11.1, 11.2, 11.3, 11.4
func test_all_required_nodes_exist() -> void:
	var test_name = "Test 2: All required nodes exist in scene tree"
	print("\nRunning: " + test_name)
	
	# Load and instantiate the scene
	practice_scene = load("res://scenes/practice_mode.tscn")
	var scene_instance = practice_scene.instantiate()
	add_child(scene_instance)
	await get_tree().process_frame
	
	# Define required nodes
	var required_nodes = {
		"Pitch": "MeshInstance3D",  # Pitch surface
		"Goal": "Area3D",  # Goal with net physics
		"Ball": "RigidBody3D",  # Ball with realistic physics
		"Camera3D": "Camera3D",  # Camera
		"DirectionalLight3D": "DirectionalLight3D",  # Lighting
		"WorldEnvironment": "WorldEnvironment"  # Environment
	}
	
	var all_nodes_exist = true
	var missing_nodes: Array[String] = []
	var wrong_type_nodes: Array[String] = []
	
	# Check each required node
	for node_name in required_nodes.keys():
		var expected_type = required_nodes[node_name]
		var node = scene_instance.get_node_or_null(node_name)
		
		if node == null:
			all_nodes_exist = false
			missing_nodes.append(node_name)
			print("  ✗ Missing node: " + node_name)
		else:
			# Check if node is of correct type
			var is_correct_type = node.get_class() == expected_type or node.is_class(expected_type)
			if not is_correct_type:
				all_nodes_exist = false
				wrong_type_nodes.append(node_name + " (expected " + expected_type + ", got " + node.get_class() + ")")
				print("  ✗ Wrong type: " + node_name + " (expected " + expected_type + ", got " + node.get_class() + ")")
			else:
				print("  ✓ Found: " + node_name + " (" + expected_type + ")")
	
	# Additional checks for nested nodes
	var pitch_collision = scene_instance.get_node_or_null("Pitch/StaticBody3D/CollisionShape3D")
	if pitch_collision == null:
		all_nodes_exist = false
		missing_nodes.append("Pitch/StaticBody3D/CollisionShape3D")
		print("  ✗ Missing pitch collision shape")
	else:
		print("  ✓ Found: Pitch collision shape")
	
	var goal_collision = scene_instance.get_node_or_null("Goal/CollisionShape3D")
	if goal_collision == null:
		all_nodes_exist = false
		missing_nodes.append("Goal/CollisionShape3D")
		print("  ✗ Missing goal collision shape")
	else:
		print("  ✓ Found: Goal collision shape")
	
	var ball_mesh = scene_instance.get_node_or_null("Ball/MeshInstance3D")
	if ball_mesh == null:
		all_nodes_exist = false
		missing_nodes.append("Ball/MeshInstance3D")
		print("  ✗ Missing ball mesh")
	else:
		print("  ✓ Found: Ball mesh")
	
	var ball_collision = scene_instance.get_node_or_null("Ball/CollisionShape3D")
	if ball_collision == null:
		all_nodes_exist = false
		missing_nodes.append("Ball/CollisionShape3D")
		print("  ✗ Missing ball collision shape")
	else:
		print("  ✓ Found: Ball collision shape")
	
	# Verify ball physics properties
	var ball = scene_instance.get_node_or_null("Ball")
	if ball and ball is RigidBody3D:
		var correct_mass = absf(ball.mass - 0.43) < 0.01
		if correct_mass:
			print("  ✓ Ball mass is correct (0.43 kg)")
		else:
			print("  ✗ Ball mass is incorrect (expected 0.43, got " + str(ball.mass) + ")")
			all_nodes_exist = false
	
	# Final result
	if all_nodes_exist:
		_pass_test(test_name)
		print("\n  ✓ All required nodes exist with correct types")
	else:
		_fail_test(test_name)
		if missing_nodes.size() > 0:
			print("\n  ✗ Missing nodes: " + str(missing_nodes))
		if wrong_type_nodes.size() > 0:
			print("  ✗ Wrong type nodes: " + str(wrong_type_nodes))
	
	# Clean up
	scene_instance.queue_free()
	await get_tree().process_frame


## Record test pass
func _pass_test(test_name: String) -> void:
	tests_passed += 1
	test_results.append("✓ " + test_name)


## Record test failure
func _fail_test(test_name: String) -> void:
	tests_failed += 1
	test_results.append("✗ " + test_name)


## Print test results summary
func _print_results() -> void:
	print("\n=== TEST RESULTS ===")
	print("Total tests: " + str(tests_passed + tests_failed))
	print("Passed: " + str(tests_passed))
	print("Failed: " + str(tests_failed))
	print("\nDetailed results:")
	for result in test_results:
		print("  " + result)
	
	if tests_failed == 0:
		print("\n✓ ALL TESTS PASSED")
	else:
		print("\n✗ SOME TESTS FAILED")
