class_name FeedbackManager
extends Node

## Coordinates all audio, visual, and UI feedback
## Validates: Requirements 3.3, 3.4, 4.2, 4.3, 4.4, 5.4

# Preload required classes
const StrikeData = preload("res://scripts/strike_data.gd")

# Feedback subsystem references
var audio_feedback: Node
var camera_feedback: Camera3D
var ui_feedback: Control

# Timing constants
const ZOUT_AUDIO_DELAY: float = 0.4  # Delay after goal detection before Zout audio - ensures ball is visually in goal
const SCORE_DISPLAY_DELAY: float = 0.3  # Delay after Zout before score display

# State tracking
var pending_zout: bool = false
var pending_score: int = 0
var is_top_bins: bool = false


func _ready() -> void:
	# Find feedback subsystems in scene
	audio_feedback = get_node_or_null("../AudioFeedback")
	camera_feedback = get_node_or_null("../Camera") as Camera3D
	ui_feedback = get_node_or_null("../UIFeedback") as Control
	
	# Warn if subsystems are missing
	if audio_feedback == null:
		push_warning("AudioFeedback not found in scene")
	
	if camera_feedback == null:
		push_warning("CameraFeedback not found in scene")
	
	if ui_feedback == null:
		push_warning("UIFeedback not found in scene")


## Trigger Zout feedback for goals
## Coordinates audio, camera, and UI feedback with proper timing
## Validates: Requirements 3.3, 3.4, 4.2, 4.3, 4.4, 5.4
func trigger_zout(top_bins: bool, quality: StrikeData.ContactQuality, score: int) -> void:
	is_top_bins = top_bins
	pending_score = score
	
	# Hide UI for clean Zout moment
	if ui_feedback != null:
		ui_feedback.hide_all_ui()
	
	# Apply camera hold with slowmo
	if camera_feedback != null:
		camera_feedback.apply_zout_hold(is_top_bins)
	
	# Play Zout audio after delay (0.1s after detection)
	await get_tree().create_timer(ZOUT_AUDIO_DELAY).timeout
	
	if audio_feedback != null:
		audio_feedback.play_zout_audio(is_top_bins)
	
	# Display score after additional delay (0.3s after Zout)
	# Note: Total delay from detection is 0.1s + 0.3s = 0.4s
	# But score display has its own internal delay of 0.3s from when show_score_popup is called
	# So we call it immediately after Zout audio
	if ui_feedback != null:
		ui_feedback.show_score_popup(pending_score)


## Trigger miss feedback
## Provides minimal feedback for missed shots
func trigger_miss() -> void:
	# For misses, we keep it minimal - no special feedback
	# Just ensure UI is visible again if it was hidden
	if ui_feedback != null:
		# Don't show anything special for misses
		pass
	
	# Reset camera to default if needed
	if camera_feedback != null:
		# Camera will naturally return to default through its own reset logic
		pass


## Trigger strike feedback (immediate on contact)
## Plays strike audio and applies camera shake
func trigger_strike(quality: StrikeData.ContactQuality) -> void:
	# Play strike audio immediately (0 frames delay)
	if audio_feedback != null:
		audio_feedback.play_strike_audio(quality)
	
	# Apply camera shake on impact
	if camera_feedback != null:
		camera_feedback.apply_impact_shake()


## Update power bar during charging
func update_power_display(power: float) -> void:
	if ui_feedback != null:
		ui_feedback.update_power_bar(power)


## Show power bar when charging starts
func show_power_bar() -> void:
	if ui_feedback != null:
		ui_feedback.show_power_bar()


## Apply camera push-in during charge
func apply_charge_camera() -> void:
	if camera_feedback != null:
		camera_feedback.apply_charge_push()


## Stop camera push-in when charge ends
func stop_charge_camera() -> void:
	if camera_feedback != null:
		camera_feedback.stop_charge_push()


## Reset all feedback systems
func reset_feedback() -> void:
	# Reset camera to default
	if camera_feedback != null:
		camera_feedback.reset_to_default()
	
	# Hide all UI
	if ui_feedback != null:
		ui_feedback.hide_all_ui()
	
	# Clear pending state
	pending_zout = false
	pending_score = 0
	is_top_bins = false


## Play net impact audio
func trigger_net_impact() -> void:
	if audio_feedback != null:
		audio_feedback.play_net_audio()
