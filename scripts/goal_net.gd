extends MeshInstance3D

## Goal Net Physics - Animates net when ball hits it

@export var spring_strength: float = 12.0
@export var damping: float = 0.85
@export var max_deformation: float = 1.5

var original_mesh: Mesh
var is_deforming: bool = false
var deformation_velocity: Vector3 = Vector3.ZERO
var current_deformation: Vector3 = Vector3.ZERO
var ball_to_stop: RigidBody3D = null


func _ready():
	# Store original mesh
	original_mesh = mesh


func trigger_net_effect(ball: RigidBody3D, impact_point: Vector3):
	"""Trigger net deformation when ball hits"""
	if is_deforming:
		return
	
	is_deforming = true
	ball_to_stop = ball
	
	# Calculate deformation direction (push net backward)
	var local_impact = to_local(impact_point)
	var deform_direction = Vector3(0, 0, -1)  # Push backward
	
	# Add slight randomness based on impact point
	deform_direction.x = local_impact.x * 0.3
	deform_direction.y = local_impact.y * 0.2
	
	# Set initial velocity for spring simulation
	var ball_speed = ball.linear_velocity.length()
	deformation_velocity = deform_direction * min(ball_speed * 0.15, max_deformation)
	
	print("🥅 Net impact! Ball speed: ", ball_speed)


func _physics_process(delta):
	if not is_deforming:
		return
	
	# Spring physics simulation
	var spring_force = -current_deformation * spring_strength
	deformation_velocity += spring_force * delta
	deformation_velocity *= damping
	
	current_deformation += deformation_velocity * delta
	
	# Apply deformation to mesh transform
	var deform_scale = 1.0 + abs(current_deformation.z) * 0.1
	scale = Vector3(deform_scale, deform_scale, 1.0)
	
	# Slightly move the net backward
	position.z = current_deformation.z * 0.3
	
	# Stop the ball during peak deformation
	if ball_to_stop and abs(current_deformation.z) > 0.3:
		ball_to_stop.linear_velocity *= 0.75
		ball_to_stop.angular_velocity *= 0.8
	
	# Reset when oscillation settles
	if abs(deformation_velocity.length()) < 0.05 and abs(current_deformation.length()) < 0.05:
		reset_net()


func reset_net():
	"""Reset net to original state"""
	is_deforming = false
	current_deformation = Vector3.ZERO
	deformation_velocity = Vector3.ZERO
	scale = Vector3.ONE
	position.z = 0
	
	# Gently slow the ball but don't freeze it completely
	if ball_to_stop:
		ball_to_stop.linear_velocity *= 0.1
		ball_to_stop.angular_velocity *= 0.1
		ball_to_stop = null
	
	print("🥅 Net settled")
