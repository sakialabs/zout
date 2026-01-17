extends Node3D

var cloud_speed = 0.5
var clouds = []

func _ready():
	# Get all cloud nodes
	for child in get_children():
		if child.name.begins_with("Cloud"):
			clouds.append(child)

func _process(delta):
	# Move clouds slowly to the right
	for cloud in clouds:
		cloud.position.x += cloud_speed * delta
		
		# Reset position when off screen
		if cloud.position.x > 60:
			cloud.position.x = -60
