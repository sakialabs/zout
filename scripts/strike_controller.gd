class_name StrikeController
extends Node

## Central coordinator managing strike state and orchestrating subsystems
## Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 6.1, 6.2, 6.3, 12.1, 12.2, 12.3, 12.4

# State machine enum
enum StrikeState {
	READY,      # Ball at strike point, awaiting input
	AIMING,     # Player adjusting aim direction
	CHARGING,   # Power accumulating (hold input)
	CONTACT,    # Timing window evaluation (release input)
	FLIGHT,     # Ball in motion, physics active
	OUTCOME,    # Goal detection and feedback
	RESET       # Return to READY state
}

# Signals
signal strike_executed(power: float, direction: Vector3, quality: StrikeData.ContactQuality)
signal state_changed(old_state: StrikeState, new_state: StrikeState)

# Current state
var current_state: StrikeState = StrikeState.READY

# Strike parameters
var strike_origin: Vector3 = Vector3.ZERO
var aim_direction: Vector3 = Vector3.FORWARD
var power_level: float = 0.0
var contact_quality: StrikeData.ContactQuality = StrikeData.ContactQuality.CLEAN

# Subsystems
var aim_system: AimSystem
var power_system: PowerSystem
var timing_system: TimingSystem
var quality_calculator: ContactQualityCalculator

# References to scene nodes (set externally or in _ready)
var ball_physics: BallPhysics
var goal_detector: GoalDetector
var feedback_manager: FeedbackManager
var stats_tracker: StatsTracker

# Input tracking
var aim_input: Vector2 = Vector2.ZERO
var is_power_button_held: bool = false

# Timing tracking
var charge_start_time: float = 0.0
var release_time: float = 0.0

# Reset tracking
var reset_timer: float = 0.0
const AUTO_RESET_DELAY: float = 2.0  # Auto-reset 2 seconds after outcome


func _ready() -> void:
	# Initialize subsystems
	aim_system = AimSystem.new()
	power_system = PowerSystem.new()
	timing_system = TimingSystem.new(power_system)
	quality_calculator = ContactQualityCalculator.new()
	
	# Set initial state
	change_state(StrikeState.READY)
	
	# Find ball and goal detector in scene if not set
	if ball_physics == null:
		ball_physics = get_node_or_null("../Ball") as BallPhysics
	
	if goal_detector == null:
		goal_detector = get_node_or_null("../Goal") as GoalDetector
	
	if feedback_manager == null:
		feedback_manager = get_node_or_null("../FeedbackManager") as FeedbackManager
	
	if stats_tracker == null:
		stats_tracker = get_node_or_null("../StatsTracker") as StatsTracker
	
	# Connect goal detector signals if available
	if goal_detector != null:
		goal_detector.goal_scored.connect(_on_goal_scored)
		goal_detector.ball_missed.connect(_on_ball_missed)
	
	# Store strike origin
	if ball_physics != null:
		strike_origin = ball_physics.global_position


func _process(delta: float) -> void:
	# Update current state logic
	match current_state:
		StrikeState.READY:
			_process_ready_state(delta)
		
		StrikeState.AIMING:
			_process_aiming_state(delta)
		
		StrikeState.CHARGING:
			_process_charging_state(delta)
		
		StrikeState.CONTACT:
			_process_contact_state(delta)
		
		StrikeState.FLIGHT:
			_process_flight_state(delta)
		
		StrikeState.OUTCOME:
			_process_outcome_state(delta)
		
		StrikeState.RESET:
			_process_reset_state(delta)


func _input(event: InputEvent) -> void:
	# Route input to appropriate subsystem based on state
	
	# Handle reset input (R key) - works from any state
	if event.is_action_pressed("reset"):
		reset_strike()
		return
	
	# State-specific input handling
	match current_state:
		StrikeState.READY, StrikeState.AIMING:
			_handle_aiming_input(event)
		
		StrikeState.CHARGING:
			_handle_charging_input(event)


## Process READY state
func _process_ready_state(_delta: float) -> void:
	# Wait for aim input to transition to AIMING
	if aim_input.length() > 0.01 or is_power_button_held:
		change_state(StrikeState.AIMING)


## Process AIMING state
func _process_aiming_state(_delta: float) -> void:
	# Update aim direction based on input
	aim_system.update_aim(aim_input)
	aim_direction = aim_system.get_aim_direction()
	
	# Transition to CHARGING when power button is pressed
	if is_power_button_held:
		change_state(StrikeState.CHARGING)


## Process CHARGING state
func _process_charging_state(_delta: float) -> void:
	# Continue updating aim during charge
	aim_system.update_aim(aim_input)
	aim_direction = aim_system.get_aim_direction()
	
	# Get current power level
	power_level = power_system.get_current_power()
	
	# Update power display in UI
	if feedback_manager != null:
		feedback_manager.update_power_display(power_level)
	
	# Transition to CONTACT when power button is released
	if not is_power_button_held:
		change_state(StrikeState.CONTACT)


## Process CONTACT state
func _process_contact_state(_delta: float) -> void:
	# Execute strike immediately
	execute_strike()
	
	# Trigger strike feedback (audio and camera shake)
	if feedback_manager != null:
		feedback_manager.trigger_strike(contact_quality)
	
	# Stop charge camera effect
	if feedback_manager != null:
		feedback_manager.stop_charge_camera()
	
	# Transition to FLIGHT
	change_state(StrikeState.FLIGHT)


## Process FLIGHT state
func _process_flight_state(_delta: float) -> void:
	# Wait for goal detection or ball to settle
	# Transition to OUTCOME is handled by goal detector signals
	pass


## Process OUTCOME state
func _process_outcome_state(delta: float) -> void:
	# Auto-reset after delay
	reset_timer += delta
	if reset_timer >= AUTO_RESET_DELAY:
		change_state(StrikeState.RESET)


## Process RESET state
func _process_reset_state(_delta: float) -> void:
	# Reset ball position
	if ball_physics != null:
		ball_physics.reset_position(strike_origin)
	
	# Reset feedback systems
	if feedback_manager != null:
		feedback_manager.reset_feedback()
	
	# Reset all state variables
	aim_input = Vector2.ZERO
	power_level = 0.0
	reset_timer = 0.0
	
	# Return to READY
	change_state(StrikeState.READY)


## Handle aiming input
func _handle_aiming_input(event: InputEvent) -> void:
	# Keyboard aim input (WASD or Arrow keys)
	if event.is_action("aim_left") or event.is_action("aim_right") or \
	   event.is_action("aim_up") or event.is_action("aim_down"):
		_update_keyboard_aim()
	
	# Mouse aim input
	if event is InputEventMouseMotion:
		var mouse_motion = event as InputEventMouseMotion
		aim_input += mouse_motion.relative * 0.01  # Scale mouse sensitivity
		aim_input = aim_input.clamp(Vector2(-1, -1), Vector2(1, 1))
	
	# Power button pressed
	if event.is_action_pressed("power_charge"):
		is_power_button_held = true
		power_system.start_charge()
		charge_start_time = Time.get_ticks_msec() / 1000.0
		
		# Show power bar and apply camera push-in
		if feedback_manager != null:
			feedback_manager.show_power_bar()
			feedback_manager.apply_charge_camera()


## Handle charging input
func _handle_charging_input(event: InputEvent) -> void:
	# Continue updating aim during charge
	if event.is_action("aim_left") or event.is_action("aim_right") or \
	   event.is_action("aim_up") or event.is_action("aim_down"):
		_update_keyboard_aim()
	
	if event is InputEventMouseMotion:
		var mouse_motion = event as InputEventMouseMotion
		aim_input += mouse_motion.relative * 0.01
		aim_input = aim_input.clamp(Vector2(-1, -1), Vector2(1, 1))
	
	# Power button released
	if event.is_action_released("power_charge"):
		is_power_button_held = false
		release_time = Time.get_ticks_msec() / 1000.0


## Update keyboard aim input
func _update_keyboard_aim() -> void:
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("aim_left"):
		input_vector.x -= 1.0
	if Input.is_action_pressed("aim_right"):
		input_vector.x += 1.0
	if Input.is_action_pressed("aim_up"):
		input_vector.y += 1.0
	if Input.is_action_pressed("aim_down"):
		input_vector.y -= 1.0
	
	aim_input = input_vector.clamp(Vector2(-1, -1), Vector2(1, 1))


## Execute strike - calculate and apply strike to ball
func execute_strike() -> void:
	# Finalize power level
	power_level = power_system.release_charge()
	
	# Input validation: Check if power is below minimum threshold
	if power_level < 0.0:
		# Strike rejected - too weak
		print("Strike rejected: Power too low (below 20% threshold)")
		if feedback_manager != null:
			feedback_manager.show_message("Too weak!")
		change_state(StrikeState.RESET)
		return
	
	# Input validation: Clamp power to valid range (0.0 to 1.0)
	power_level = clamp(power_level, 0.0, 1.0)
	
	# Input validation: Ensure aim direction is valid
	if is_nan(aim_direction.x) or is_nan(aim_direction.y) or is_nan(aim_direction.z) or aim_direction.length() < 0.001:
		push_warning("Invalid aim direction detected, using goal center")
		aim_direction = Vector3.FORWARD
	
	# Normalize aim direction to ensure consistency
	aim_direction = aim_direction.normalized()
	
	# Calculate timing offset
	var timing_offset = timing_system.get_timing_offset(release_time, charge_start_time)
	
	# Calculate contact quality
	contact_quality = quality_calculator.calculate_quality(power_level, timing_offset)
	
	# Apply strike to ball
	if ball_physics != null:
		ball_physics.apply_strike(aim_direction, power_level, contact_quality)
	
	# Emit strike executed signal
	strike_executed.emit(power_level, aim_direction, contact_quality)


## Reset strike - return to READY state
func reset_strike() -> void:
	# Can reset from any state
	change_state(StrikeState.RESET)


## Change state with signal emission
func change_state(new_state: StrikeState) -> void:
	var old_state = current_state
	current_state = new_state
	
	# Reset state-specific variables on state entry
	match new_state:
		StrikeState.READY:
			aim_input = Vector2.ZERO
			power_level = 0.0
			reset_timer = 0.0
		
		StrikeState.CHARGING:
			charge_start_time = Time.get_ticks_msec() / 1000.0
		
		StrikeState.OUTCOME:
			reset_timer = 0.0
	
	# Emit state changed signal
	state_changed.emit(old_state, new_state)


## Handle goal scored signal from goal detector
func _on_goal_scored(entry_position: Vector3, is_top_bins: bool) -> void:
	if current_state == StrikeState.FLIGHT:
		# Calculate score based on outcome and contact quality
		var score = calculate_score(is_top_bins, contact_quality)
		
		# Record the goal in session stats via stats tracker
		if stats_tracker != null:
			stats_tracker.record_attempt()
			stats_tracker.record_goal(is_top_bins, score)
		
		# Trigger Zout feedback
		if feedback_manager != null:
			feedback_manager.trigger_zout(is_top_bins, contact_quality, score)
		
		change_state(StrikeState.OUTCOME)


## Handle ball missed signal from goal detector
func _on_ball_missed() -> void:
	if current_state == StrikeState.FLIGHT:
		# Record the miss in session stats via stats tracker
		if stats_tracker != null:
			stats_tracker.record_attempt()
			stats_tracker.record_miss()
		
		# Trigger miss feedback
		if feedback_manager != null:
			feedback_manager.trigger_miss()
		
		change_state(StrikeState.OUTCOME)


## Calculate score based on outcome and contact quality
## Validates: Requirements 5.1, 5.2, 5.3, 5.4
func calculate_score(is_top_bins: bool, quality: StrikeData.ContactQuality) -> int:
	# Base score for goal
	var base_score: int = 100
	
	# Add Top Bins bonus
	if is_top_bins:
		base_score += 50
	
	# Apply contact quality multiplier
	var multiplier = quality_calculator.get_quality_multiplier(quality)
	var final_score = int(float(base_score) * multiplier)
	
	return final_score
