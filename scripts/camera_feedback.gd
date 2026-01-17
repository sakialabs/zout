class_name CameraFeedback
extends Camera3D

## Camera3D with dynamic behavior responding to strike phases
## Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.5

# Default camera properties
var default_position: Vector3 = Vector3(0, 5, -25)  # Behind ball, elevated view
var default_rotation: Vector3 = Vector3(-20, 0, 0)  # Looking slightly down
var default_fov: float = 75.0

# Camera effect properties (Task 24 - Tuned for better feel)
var shake_intensity: float = 0.08  # Subtle micro shake, not distracting
var slowmo_factor: float = 0.7  # Time scale for Zout moments (feels right!)
var push_in_distance: float = 0.3  # Gentle camera movement during charge

# State tracking
var is_pushing_in: bool = false
var is_shaking: bool = false
var is_holding: bool = false
var original_position: Vector3 = Vector3.ZERO
var shake_offset: Vector3 = Vector3.ZERO
var push_in_progress: float = 0.0  # 0.0 to 1.0
var hold_timer: float = 0.0
var hold_duration: float = 0.25  # Brief hold - no long pauses (Task 24)
var top_bins_hold_duration: float = 0.35  # Slightly longer but still quick

# Smoothing (Task 24 - Refined for fluid motion)
var push_in_speed: float = 2.5  # Slightly faster push-in for responsiveness
var reset_speed: float = 4.0  # Quick return to default - no lingering

# Failsafe tracking
var time_scale_failsafe_timer: float = 0.0
const TIME_SCALE_FAILSAFE_DURATION: float = 2.0  # Force restore after 2 seconds


func _ready() -> void:
	# Set default camera properties
	fov = default_fov
	position = default_position
	rotation_degrees = default_rotation
	
	# Store original position
	original_position = default_position


func _process(delta: float) -> void:
	# Update camera effects
	_update_push_in(delta)
	_update_shake(delta)
	_update_hold(delta)
	
	# Validate camera position (error handling)
	_validate_camera_position()
	
	# Time scale failsafe - force restore if stuck
	if Engine.time_scale != 1.0:
		time_scale_failsafe_timer += delta
		if time_scale_failsafe_timer >= TIME_SCALE_FAILSAFE_DURATION:
			push_warning("Time scale failsafe triggered - forcing restore to 1.0")
			Engine.time_scale = 1.0
			time_scale_failsafe_timer = 0.0
			is_holding = false
	else:
		time_scale_failsafe_timer = 0.0


## Apply subtle camera push-in during power charge
## Validates: Requirements 9.2
func apply_charge_push() -> void:
	is_pushing_in = true
	push_in_progress = 0.0


## Update push-in effect
func _update_push_in(delta: float) -> void:
	if is_pushing_in:
		# Smoothly push camera forward
		push_in_progress = min(push_in_progress + delta * push_in_speed, 1.0)
		
		# Calculate push-in offset (move camera closer to ball)
		var push_offset = Vector3(0, 0, push_in_distance) * push_in_progress
		position = default_position + push_offset + shake_offset
	elif push_in_progress > 0.0:
		# Smoothly return to default position
		push_in_progress = max(push_in_progress - delta * reset_speed, 0.0)
		
		var push_offset = Vector3(0, 0, push_in_distance) * push_in_progress
		position = default_position + push_offset + shake_offset


## Apply micro camera shake on ball contact
## Validates: Requirements 9.3
func apply_impact_shake() -> void:
	is_shaking = true
	
	# Generate random shake offset
	shake_offset = Vector3(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	
	# Apply shake immediately
	var push_offset = Vector3(0, 0, push_in_distance) * push_in_progress
	position = default_position + push_offset + shake_offset


## Update shake effect (decay quickly)
func _update_shake(delta: float) -> void:
	if is_shaking:
		# Decay shake offset quickly
		shake_offset = shake_offset.lerp(Vector3.ZERO, delta * 10.0)
		
		# Update position
		var push_offset = Vector3(0, 0, push_in_distance) * push_in_progress
		position = default_position + push_offset + shake_offset
		
		# Stop shaking when offset is negligible
		if shake_offset.length() < 0.01:
			is_shaking = false
			shake_offset = Vector3.ZERO


## Apply brief hold with slowmo for Zout moments
## Validates: Requirements 9.4, 9.5
## Task 24: Subtle camera emphasis for Top Bins (slight corner framing)
func apply_zout_hold(is_top_bins: bool = false, entry_position: Vector3 = Vector3.ZERO) -> void:
	is_holding = true
	hold_timer = 0.0
	time_scale_failsafe_timer = 0.0  # Reset failsafe timer
	
	# Set hold duration based on whether it's Top Bins
	if is_top_bins:
		hold_duration = top_bins_hold_duration
		
		# Subtle camera pan toward the corner (Task 24 - slight emphasis, not forced)
		if entry_position != Vector3.ZERO:
			var corner_offset = (entry_position - position).normalized() * 0.15
			position += Vector3(corner_offset.x, 0, 0)  # Only horizontal shift
	else:
		hold_duration = hold_duration
	
	# Apply slowmo time scale
	Engine.time_scale = slowmo_factor
	
	# Stop push-in effect during hold
	is_pushing_in = false


## Update hold effect
func _update_hold(delta: float) -> void:
	if is_holding:
		hold_timer += delta
		
		# End hold after duration
		if hold_timer >= hold_duration:
			is_holding = false
			
			# Restore normal time scale
			Engine.time_scale = 1.0
			time_scale_failsafe_timer = 0.0


## Validate camera position and reset if invalid (error handling)
func _validate_camera_position() -> void:
	# Check for NaN or invalid position
	if position.is_nan() or position.length() > 1000.0:
		push_warning("Invalid camera position detected, resetting to default")
		position = default_position
		rotation_degrees = default_rotation
		
		# Reset all effects
		is_pushing_in = false
		is_shaking = false
		is_holding = false
		push_in_progress = 0.0
		shake_offset = Vector3.ZERO
		
		# Restore time scale
		Engine.time_scale = 1.0
		time_scale_failsafe_timer = 0.0


## Reset camera to default position
## Validates: Requirements 9.1
func reset_to_default() -> void:
	# Stop all effects
	is_pushing_in = false
	is_shaking = false
	is_holding = false
	
	# Reset state
	push_in_progress = 0.0
	shake_offset = Vector3.ZERO
	hold_timer = 0.0
	
	# Restore time scale (failsafe)
	Engine.time_scale = 1.0
	time_scale_failsafe_timer = 0.0
	
	# Reset position and rotation
	position = default_position
	rotation_degrees = default_rotation
	fov = default_fov


## Stop charge push-in effect (called when power is released)
func stop_charge_push() -> void:
	is_pushing_in = false


## Set default camera position (useful for scene setup)
func set_default_position(pos: Vector3, rot: Vector3) -> void:
	default_position = pos
	default_rotation = rot
	original_position = pos
	
	# Apply immediately if not in an effect
	if not is_pushing_in and not is_shaking and not is_holding:
		position = default_position
		rotation_degrees = default_rotation
