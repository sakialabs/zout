class_name AimSystem
extends RefCounted

## Handles aim input and direction calculation
## Validates: Requirements 1.1, 12.1

# Configuration
var aim_sensitivity: float = 1.0
var aim_cone_angle_horizontal: float = 45.0  # degrees
var aim_cone_angle_vertical: float = 30.0    # degrees

# Current aim state (normalized -1 to 1 for X/Y)
var current_aim: Vector2 = Vector2.ZERO

# Goal center direction (default forward)
var goal_center_direction: Vector3 = Vector3.FORWARD


## Update aim based on input vector
## input_vector: Normalized input from keyboard/mouse (-1 to 1 for X/Y)
func update_aim(input_vector: Vector2) -> void:
	current_aim = input_vector
	# Clamp to normalized range
	current_aim.x = clamp(current_aim.x, -1.0, 1.0)
	current_aim.y = clamp(current_aim.y, -1.0, 1.0)


## Convert 2D aim input to 3D world direction
## Returns a normalized Vector3 direction clamped within the aim cone
func get_aim_direction() -> Vector3:
	# Handle zero vector - default to goal center
	if current_aim.length() < 0.001:
		return goal_center_direction.normalized()
	
	# Clamp aim input to ensure it's within valid range (error handling)
	var clamped_aim = Vector2(
		clamp(current_aim.x, -1.0, 1.0),
		clamp(current_aim.y, -1.0, 1.0)
	)
	
	# Convert horizontal aim (-1 to 1) to angle within cone
	var horizontal_angle = clamped_aim.x * deg_to_rad(aim_cone_angle_horizontal)
	
	# Convert vertical aim (-1 to 1) to angle within cone
	var vertical_angle = clamped_aim.y * deg_to_rad(aim_cone_angle_vertical)
	
	# Clamp angles to cone bounds (additional safety check)
	horizontal_angle = clamp(horizontal_angle, -deg_to_rad(aim_cone_angle_horizontal), deg_to_rad(aim_cone_angle_horizontal))
	vertical_angle = clamp(vertical_angle, -deg_to_rad(aim_cone_angle_vertical), deg_to_rad(aim_cone_angle_vertical))
	
	# Start with goal center direction (forward)
	var direction = goal_center_direction
	
	# Apply horizontal rotation (around Y axis)
	direction = direction.rotated(Vector3.UP, horizontal_angle)
	
	# Apply vertical rotation (around right axis)
	var right_axis = direction.cross(Vector3.UP).normalized()
	direction = direction.rotated(right_axis, -vertical_angle)
	
	# Validate direction is not NaN or invalid
	if direction.is_nan() or direction.length() < 0.001:
		push_warning("Invalid aim direction calculated, defaulting to goal center")
		return goal_center_direction.normalized()
	
	return direction.normalized()


## Get vertices for aim cone visualization
## Returns an array of Vector3 points representing the cone boundary
func get_aim_cone_vertices() -> Array[Vector3]:
	var vertices: Array[Vector3] = []
	var segments = 16  # Number of segments around the cone
	
	# Cone origin (strike point)
	var origin = Vector3.ZERO
	
	# Cone tip distance (for visualization)
	var cone_distance = 10.0
	
	# Generate vertices around the cone perimeter
	for i in range(segments + 1):
		var angle = (float(i) / float(segments)) * TAU  # Full circle
		
		# Calculate position on cone edge
		var horizontal_offset = sin(angle) * deg_to_rad(aim_cone_angle_horizontal)
		var vertical_offset = cos(angle) * deg_to_rad(aim_cone_angle_vertical)
		
		# Create direction vector
		var direction = goal_center_direction
		direction = direction.rotated(Vector3.UP, horizontal_offset)
		var right_axis = direction.cross(Vector3.UP).normalized()
		direction = direction.rotated(right_axis, -vertical_offset)
		
		# Scale to cone distance
		var vertex = origin + direction.normalized() * cone_distance
		vertices.append(vertex)
	
	return vertices

