class_name BallPhysics
extends RigidBody3D

## Ball physics with quality-based drift and behavior
## Validates: Requirements 1.5, 2.1, 2.2, 2.3, 2.4, 11.3

# Physics constants
const BALL_MASS: float = 0.43  # Regulation ball mass in kg
const BASE_SPEED: float = 30.0  # Maximum ball velocity in m/s
const DRAG_COEFFICIENT: float = 0.47  # Air resistance coefficient

# Quality-based drift angles (in degrees)
const PERFECT_DRIFT: float = 0.0   # No drift
const CLEAN_DRIFT: float = 2.0     # ≤2° drift
const OKAY_DRIFT: float = 5.0      # ≤5° drift
const SCUFFED_DRIFT: float = 10.0  # ≤10° drift

# Quality-based speed efficiency
const PERFECT_EFFICIENCY: float = 1.0   # 100% speed
const CLEAN_EFFICIENCY: float = 0.95    # 95% speed
const OKAY_EFFICIENCY: float = 0.85     # 85% speed
const SCUFFED_EFFICIENCY: float = 0.70  # 70% speed

# Edge case detection
const STUCK_VELOCITY_THRESHOLD: float = 0.1  # m/s
const STUCK_TIME_THRESHOLD: float = 3.0      # seconds
const OUT_OF_BOUNDS_DISTANCE: float = 50.0   # meters from origin

var strike_origin: Vector3 = Vector3.ZERO
var stuck_timer: float = 0.0


func _ready() -> void:
	# Set ball mass
	mass = BALL_MASS
	
	# Configure physics properties
	linear_damp = DRAG_COEFFICIENT
	angular_damp = 0.1
	
	# Store initial position as strike origin
	strike_origin = global_position


func _physics_process(delta: float) -> void:
	# Edge case handling: Check for stuck ball
	if linear_velocity.length() < STUCK_VELOCITY_THRESHOLD:
		stuck_timer += delta
		if stuck_timer >= STUCK_TIME_THRESHOLD:
			push_warning("Ball stuck detected - auto-resetting")
			reset_position(strike_origin)
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0
	
	# Edge case handling: Check for out of bounds
	var distance_from_origin = global_position.distance_to(strike_origin)
	if distance_from_origin > OUT_OF_BOUNDS_DISTANCE:
		push_warning("Ball out of bounds detected - auto-resetting")
		reset_position(strike_origin)
	
	# Edge case handling: Check for invalid position (NaN)
	if is_nan(global_position.x) or is_nan(global_position.y) or is_nan(global_position.z):
		push_error("Ball position is NaN - emergency reset")
		reset_position(strike_origin)


## Apply strike to ball with direction, power, and quality effects
## direction: Normalized aim direction vector
## power: Power level from 0.0 to 1.0
## quality: Contact quality determining drift and efficiency
func apply_strike(direction: Vector3, power: float, quality: StrikeData.ContactQuality) -> void:
	# Input validation: Ensure direction is valid
	if is_nan(direction.x) or is_nan(direction.y) or is_nan(direction.z) or direction.length() < 0.001:
		push_warning("Invalid strike direction, using forward")
		direction = Vector3.FORWARD
	
	# Input validation: Clamp power to valid range
	power = clamp(power, 0.0, 1.0)
	
	# Normalize direction to ensure consistent behavior
	var normalized_direction = direction.normalized()
	
	# Apply quality effects to get modified direction and speed
	var modified_direction = apply_quality_effects(normalized_direction, quality)
	var speed_efficiency = get_speed_efficiency(quality)
	
	# Calculate final velocity
	var final_speed = BASE_SPEED * power * speed_efficiency
	var final_velocity = modified_direction * final_speed
	
	# Validate final velocity is not NaN
	if final_velocity.is_nan():
		push_warning("Invalid final velocity calculated, resetting ball")
		reset_position(strike_origin)
		return
	
	# Apply impulse to ball
	linear_velocity = final_velocity
	
	# Add spin based on quality (scuffed shots have more spin)
	if quality == StrikeData.ContactQuality.SCUFFED:
		# Add random spin for scuffed shots
		var spin_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
		angular_velocity = spin_axis * randf_range(5.0, 10.0)


## Apply quality-based drift to direction vector
## direction: Original aim direction
## quality: Contact quality determining drift amount
## Returns: Modified direction with drift applied
func apply_quality_effects(direction: Vector3, quality: StrikeData.ContactQuality) -> Vector3:
	var drift_angle = get_drift_angle(quality)
	
	# No drift for perfect contact
	if drift_angle == 0.0:
		return direction
	
	# Generate random drift within quality bounds
	var actual_drift = randf_range(-drift_angle, drift_angle)
	
	# Apply drift by rotating around the up axis (Y)
	var drift_radians = deg_to_rad(actual_drift)
	var rotated_direction = direction.rotated(Vector3.UP, drift_radians)
	
	# Also apply slight vertical drift for non-perfect shots
	if quality != StrikeData.ContactQuality.PERFECT:
		var vertical_drift = randf_range(-drift_angle * 0.3, drift_angle * 0.3)
		var vertical_radians = deg_to_rad(vertical_drift)
		# Rotate around the right axis (perpendicular to direction and up)
		var right_axis = direction.cross(Vector3.UP).normalized()
		rotated_direction = rotated_direction.rotated(right_axis, vertical_radians)
	
	return rotated_direction.normalized()


## Get drift angle for a given contact quality
func get_drift_angle(quality: StrikeData.ContactQuality) -> float:
	match quality:
		StrikeData.ContactQuality.PERFECT:
			return PERFECT_DRIFT
		StrikeData.ContactQuality.CLEAN:
			return CLEAN_DRIFT
		StrikeData.ContactQuality.OKAY:
			return OKAY_DRIFT
		StrikeData.ContactQuality.SCUFFED:
			return SCUFFED_DRIFT
		_:
			return CLEAN_DRIFT  # Fallback


## Get speed efficiency for a given contact quality
func get_speed_efficiency(quality: StrikeData.ContactQuality) -> float:
	match quality:
		StrikeData.ContactQuality.PERFECT:
			return PERFECT_EFFICIENCY
		StrikeData.ContactQuality.CLEAN:
			return CLEAN_EFFICIENCY
		StrikeData.ContactQuality.OKAY:
			return OKAY_EFFICIENCY
		StrikeData.ContactQuality.SCUFFED:
			return SCUFFED_EFFICIENCY
		_:
			return CLEAN_EFFICIENCY  # Fallback


## Reset ball to strike origin position
## position: Target position to reset to
func reset_position(position: Vector3) -> void:
	# Stop all motion
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Reset position
	global_position = position
	
	# Update strike origin
	strike_origin = position
	
	# Reset stuck timer
	stuck_timer = 0.0
