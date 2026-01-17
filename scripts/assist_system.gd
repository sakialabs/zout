class_name AssistSystem
extends Node3D

## Optional visual guides for learning the mechanics
## Validates: Requirements 7.1, 7.2, 7.3, 7.4

# Toggle properties
var aim_assist_enabled: bool = false
var shot_preview_enabled: bool = false

# Visual components
var aim_cone_mesh: MeshInstance3D
var trajectory_mesh: MeshInstance3D

# Configuration
var cone_distance: float = 10.0
var cone_segments: int = 32
var trajectory_points: int = 50
var trajectory_time_step: float = 0.05

# Physics simulation parameters for trajectory prediction
var gravity: float = 9.8
var ball_mass: float = 0.43

# References
var aim_system: AimSystem
var strike_origin: Vector3 = Vector3.ZERO


func _ready() -> void:
	# Create aim cone mesh
	_create_aim_cone()
	
	# Create trajectory mesh
	_create_trajectory_mesh()
	
	# Both assists disabled by default
	aim_cone_mesh.visible = false
	trajectory_mesh.visible = false


## Create the aim cone mesh for visual aim indicator
func _create_aim_cone() -> void:
	aim_cone_mesh = MeshInstance3D.new()
	add_child(aim_cone_mesh)
	
	# Create cone mesh
	var mesh = ImmediateMesh.new()
	aim_cone_mesh.mesh = mesh
	
	# Create semi-transparent material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.8, 1.0, 0.3)  # Light blue, semi-transparent
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	aim_cone_mesh.material_override = material


## Create the trajectory mesh for shot preview
func _create_trajectory_mesh() -> void:
	trajectory_mesh = MeshInstance3D.new()
	add_child(trajectory_mesh)
	trajectory_mesh.name = "TrajectoryLine"
	
	# Create initial empty mesh
	var mesh = ImmediateMesh.new()
	trajectory_mesh.mesh = mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 0.0, 0.8)  # Yellow
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trajectory_mesh.material_override = material


## Toggle aim assist on/off
func toggle_aim_assist(enabled: bool) -> void:
	aim_assist_enabled = enabled
	if aim_cone_mesh:
		aim_cone_mesh.visible = enabled


## Toggle shot preview on/off
func toggle_shot_preview(enabled: bool) -> void:
	shot_preview_enabled = enabled
	if trajectory_mesh:
		trajectory_mesh.visible = enabled


## Update aim cone visualization in real-time
func update_aim_cone(direction: Vector3) -> void:
	if not aim_assist_enabled or not aim_cone_mesh or not aim_system:
		return
	
	# Get cone vertices from aim system
	var vertices = aim_system.get_aim_cone_vertices()
	
	if vertices.size() == 0:
		return
	
	# Rebuild the mesh
	var mesh = ImmediateMesh.new()
	aim_cone_mesh.mesh = mesh
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Draw cone from origin to perimeter
	var origin = strike_origin
	
	for i in range(vertices.size() - 1):
		var v1 = vertices[i]
		var v2 = vertices[i + 1]
		
		# Create triangle from origin to edge
		mesh.surface_add_vertex(origin)
		mesh.surface_add_vertex(origin + v1)
		mesh.surface_add_vertex(origin + v2)
	
	mesh.surface_end()


## Update trajectory prediction based on power and aim
func update_trajectory(power: float, direction: Vector3) -> void:
	if not shot_preview_enabled or not trajectory_mesh:
		return
	
	# Calculate initial velocity based on power
	var base_speed = 30.0  # Match BallPhysics base_speed
	var initial_velocity = direction.normalized() * (power * base_speed)
	
	# Predict trajectory points
	var points: Array[Vector3] = []
	var position = strike_origin
	var velocity = initial_velocity
	
	for i in range(trajectory_points):
		points.append(position)
		
		# Simple physics integration
		var delta_time = trajectory_time_step
		
		# Apply gravity
		velocity.y -= gravity * delta_time
		
		# Update position
		position += velocity * delta_time
		
		# Stop if ball hits ground or goes too far
		if position.y < 0 or position.length() > 100:
			break
	
	# Create line mesh from points
	if points.size() < 2:
		return
	
	var mesh = ImmediateMesh.new()
	trajectory_mesh.mesh = mesh
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	for point in points:
		mesh.surface_add_vertex(point)
	
	mesh.surface_end()


## Set the aim system reference
func set_aim_system(system: AimSystem) -> void:
	aim_system = system


## Set the strike origin position
func set_strike_origin(origin: Vector3) -> void:
	strike_origin = origin
