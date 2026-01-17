extends Node

## Integration tests for feedback coordination
## Task 16.1: Write integration tests for feedback coordination
## Validates: Requirements 3.3, 3.4, 4.2, 4.3, 4.4

# Preload required classes
const StrikeData = preload("res://scripts/strike_data.gd")

var feedback_manager: FeedbackManager
var audio_feedback: AudioFeedback
var camera_feedback: CameraFeedback
var ui_feedback: UIFeedback

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[String] = []


func _ready() -> void:
	print("\n=== FEEDBACK COORDINATION INTEGRATION TESTS ===")
	print("Task 16.1: Write integration tests for feedback coordination")
	print("Validates: Requirements 3.3, 3.4, 4.2, 4.3, 4.4\n")
	
	await _setup_feedback_systems()
	await _run_all_tests()
	_print_results()
	
	# Exit after tests complete
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _setup_feedback_systems() -> void:
	# Create feedback systems
	audio_feedback = AudioFeedback.new()
	add_child(audio_feedback)
	
	camera_feedback = CameraFeedback.new()
	add_child(camera_feedback)
	
	ui_feedback = UIFeedback.new()
	add_child(ui_feedback)
	
	# Create feedback manager
	feedback_manager = FeedbackManager.new()
	add_child(feedback_manager)
	
	# Manually set references (since we're not in a full scene)
	feedback_manager.audio_feedback = audio_feedback
	feedback_manager.camera_feedback = camera_feedback
	feedback_manager.ui_feedback = ui_feedback
	
	# Wait one frame for initialization
	await get_tree().process_frame


func _run_all_tests() -> void:
	print("Running tests...\n")
	
	await test_zout_triggers_all_feedback_systems()
	await test_top_bins_stacks_on_zout()
	await test_feedback_timing_relationships()
	await test_strike_feedback_immediate()
	await test_power_bar_updates()


func _record_test(test_name: String, passed: bool, message: String = "") -> void:
	if passed:
		tests_passed += 1
		test_results.append("✓ " + test_name)
		print("✓ " + test_name)
	else:
		tests_failed += 1
		test_results.append("✗ " + test_name + ": " + message)
		print("✗ " + test_name + ": " + message)


func _print_results() -> void:
	print("\n" + "=".repeat(60))
	print("TEST RESULTS")
	print("=".repeat(60))
	print("Total tests: " + str(tests_passed + tests_failed))
	print("Passed: " + str(tests_passed))
	print("Failed: " + str(tests_failed))
	
	if tests_failed == 0:
		print("\n✓ ALL TESTS PASSED")
	else:
		print("\n✗ SOME TESTS FAILED")
		print("\nFailed tests:")
		for result in test_results:
			if result.begins_with("✗"):
				print("  " + result)
	
	print("=".repeat(60) + "\n")


## Test: All feedback systems trigger together for Zout
## Validates: Requirements 3.3, 3.4
func test_zout_triggers_all_feedback_systems() -> void:
	# Arrange
	var is_top_bins = false
	var quality = StrikeData.ContactQuality.CLEAN
	var score = 100
	
	# Act
	feedback_manager.trigger_zout(is_top_bins, quality, score)
	
	# Wait for feedback to trigger
	await get_tree().create_timer(0.2).timeout
	
	# Assert - Camera slowmo should be applied
	var slowmo_applied = Engine.time_scale < 1.0
	_record_test("Zout triggers camera slowmo", slowmo_applied, "Expected time_scale < 1.0, got " + str(Engine.time_scale))
	
	# Assert - UI should be hidden for clean Zout moment
	var ui_hidden = not ui_feedback.power_bar.visible
	_record_test("Zout hides UI for clean moment", ui_hidden, "Power bar should be hidden")
	
	# Wait for score display
	await get_tree().create_timer(0.5).timeout
	
	# Assert - Score should be displayed after delay
	var score_displayed = ui_feedback.score_label.visible
	_record_test("Zout displays score after delay", score_displayed, "Score label should be visible")
	
	var score_correct = ui_feedback.score_label.text == "+100"
	_record_test("Zout shows correct score value", score_correct, "Expected '+100', got '" + ui_feedback.score_label.text + "'")
	
	# Cleanup - restore time scale
	Engine.time_scale = 1.0


## Test: Top Bins stacks on Zout correctly
## Validates: Requirements 4.2, 4.3, 4.4
func test_top_bins_stacks_on_zout() -> void:
	# Arrange
	var is_top_bins = true
	var quality = StrikeData.ContactQuality.PERFECT
	var score = 187  # (100 + 50) * 1.25
	
	# Act
	feedback_manager.trigger_zout(is_top_bins, quality, score)
	
	# Wait for feedback to trigger
	await get_tree().create_timer(0.2).timeout
	
	# Assert - Camera slowmo should be applied
	var slowmo_applied = Engine.time_scale < 1.0
	_record_test("Top Bins triggers camera slowmo", slowmo_applied, "Expected time_scale < 1.0")
	
	# Wait for score display
	await get_tree().create_timer(0.5).timeout
	
	# Assert - Score should show Top Bins bonus
	var score_displayed = ui_feedback.score_label.visible
	_record_test("Top Bins displays score", score_displayed, "Score label should be visible")
	
	var score_correct = ui_feedback.score_label.text == "+187"
	_record_test("Top Bins shows correct bonus score", score_correct, "Expected '+187', got '" + ui_feedback.score_label.text + "'")
	
	# Cleanup
	Engine.time_scale = 1.0


## Test: Feedback timing relationships
## Validates: Requirements 3.3, 3.4, 4.2, 4.3, 4.4
func test_feedback_timing_relationships() -> void:
	# Arrange
	var is_top_bins = false
	var quality = StrikeData.ContactQuality.CLEAN
	var score = 100
	
	# Track timing
	var start_time = Time.get_ticks_msec()
	
	# Act - Trigger strike feedback (immediate)
	feedback_manager.trigger_strike(quality)
	var strike_time = Time.get_ticks_msec() - start_time
	
	# Assert - Strike feedback should be immediate (< 50ms)
	var strike_immediate = strike_time < 50
	_record_test("Strike feedback is immediate", strike_immediate, "Expected < 50ms, got " + str(strike_time) + "ms")
	
	# Act - Trigger Zout feedback
	start_time = Time.get_ticks_msec()
	feedback_manager.trigger_zout(is_top_bins, quality, score)
	
	# Wait for Zout audio delay (0.1s)
	await get_tree().create_timer(0.15).timeout
	var zout_time = Time.get_ticks_msec() - start_time
	
	# Assert - Zout audio should play after ~0.1s delay
	var zout_timing_correct = zout_time >= 100 and zout_time <= 200
	_record_test("Zout audio timing correct", zout_timing_correct, "Expected 100-200ms, got " + str(zout_time) + "ms")
	
	# Wait for score display delay (0.3s from Zout audio)
	await get_tree().create_timer(0.35).timeout
	
	# Assert - Score should be visible
	var score_displayed = ui_feedback.score_label.visible
	_record_test("Score displays after correct delay", score_displayed, "Score should be visible after delay")
	
	# Cleanup
	Engine.time_scale = 1.0


## Test: Strike feedback is immediate
## Validates: Requirements 3.3
func test_strike_feedback_immediate() -> void:
	# Arrange
	var quality = StrikeData.ContactQuality.PERFECT
	var camera_pos_before = camera_feedback.position
	
	# Act
	var start_time = Time.get_ticks_msec()
	feedback_manager.trigger_strike(quality)
	var elapsed = Time.get_ticks_msec() - start_time
	
	# Assert - Feedback should trigger immediately (< 50ms)
	var immediate = elapsed < 50
	_record_test("Strike feedback triggers immediately", immediate, "Expected < 50ms, got " + str(elapsed) + "ms")
	
	# Wait one frame for camera shake to apply
	await get_tree().process_frame
	
	# Assert - Camera shake should be applied
	var shake_applied = camera_feedback.position != camera_pos_before
	_record_test("Camera shake applies on strike", shake_applied, "Camera position should change")


## Test: Power bar updates during charging
## Validates: Requirements 3.3
func test_power_bar_updates() -> void:
	# Arrange
	feedback_manager.show_power_bar()
	
	# Assert - Power bar should be visible
	var bar_visible = ui_feedback.power_bar.visible
	_record_test("Power bar shows when charging", bar_visible, "Power bar should be visible")
	
	# Act - Update power display
	feedback_manager.update_power_display(0.5)
	
	# Assert - Power bar should show 50%
	var power_50 = abs(ui_feedback.power_bar.value - 50.0) < 1.0
	_record_test("Power bar shows 50% correctly", power_50, "Expected ~50%, got " + str(ui_feedback.power_bar.value) + "%")
	
	# Act - Update to 100%
	feedback_manager.update_power_display(1.0)
	
	# Assert - Power bar should show 100%
	var power_100 = abs(ui_feedback.power_bar.value - 100.0) < 1.0
	_record_test("Power bar shows 100% correctly", power_100, "Expected ~100%, got " + str(ui_feedback.power_bar.value) + "%")
