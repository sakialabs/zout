extends Node3D

func _ready():
	print("🅿️ Creating parked cars...")
	create_parked_cars()
	print("✅ Parked cars created")

func create_car_model(color: Color, position: Vector3, rotation_y: float = 0) -> Node3D:
	var car_container = Node3D.new()
	car_container.position = position
	car_container.rotation_degrees.y = rotation_y
	
	# Car body (main chassis)
	var body = CSGBox3D.new()
	body.size = Vector3(3.2, 1.0, 1.6)
	body.position = Vector3(0, 0.5, 0)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = color
	body_mat.metallic = 0.75
	body_mat.roughness = 0.15
	body.material = body_mat
	car_container.add_child(body)
	
	# Car cabin/roof
	var cabin = CSGBox3D.new()
	cabin.size = Vector3(1.8, 0.75, 1.4)
	cabin.position = Vector3(-0.2, 1.375, 0)
	cabin.material = body_mat
	car_container.add_child(cabin)
	
	# Hood
	var hood = CSGBox3D.new()
	hood.size = Vector3(0.9, 0.6, 1.6)
	hood.position = Vector3(1.5, 0.6, 0)
	hood.material = body_mat
	car_container.add_child(hood)
	
	# Windows
	var window_mat = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.08, 0.1, 0.15, 0.65)
	window_mat.metallic = 0.95
	window_mat.roughness = 0.05
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var front_window = CSGBox3D.new()
	front_window.size = Vector3(0.08, 0.6, 1.3)
	front_window.position = Vector3(0.55, 1.375, 0)
	front_window.material = window_mat
	car_container.add_child(front_window)
	
	var rear_window = CSGBox3D.new()
	rear_window.size = Vector3(0.08, 0.6, 1.3)
	rear_window.position = Vector3(-1.1, 1.375, 0)
	rear_window.material = window_mat
	car_container.add_child(rear_window)
	
	# Side windows
	var left_window = CSGBox3D.new()
	left_window.size = Vector3(1.3, 0.5, 0.08)
	left_window.position = Vector3(-0.3, 1.45, 0.71)
	left_window.material = window_mat
	car_container.add_child(left_window)
	
	var right_window = CSGBox3D.new()
	right_window.size = Vector3(1.3, 0.5, 0.08)
	right_window.position = Vector3(-0.3, 1.45, -0.71)
	right_window.material = window_mat
	car_container.add_child(right_window)
	
	# Tires
	var tire_mat = StandardMaterial3D.new()
	tire_mat.albedo_color = Color(0.08, 0.08, 0.08, 1)
	tire_mat.roughness = 0.85
	
	var tire_positions = [
		Vector3(1.1, 0.35, -0.85),
		Vector3(1.1, 0.35, 0.85),
		Vector3(-1.1, 0.35, -0.85),
		Vector3(-1.1, 0.35, 0.85)
	]
	
	for tire_pos in tire_positions:
		var tire = CSGCylinder3D.new()
		tire.radius = 0.35
		tire.height = 0.25
		tire.sides = 16
		tire.position = tire_pos
		tire.rotation_degrees = Vector3(0, 0, 90)
		tire.material = tire_mat
		car_container.add_child(tire)
		
		# Rim
		var rim = CSGCylinder3D.new()
		rim.radius = 0.2
		rim.height = 0.27
		rim.sides = 12
		rim.position = tire_pos
		rim.rotation_degrees = Vector3(0, 0, 90)
		var rim_mat = StandardMaterial3D.new()
		rim_mat.albedo_color = Color(0.5, 0.5, 0.55, 1)
		rim_mat.metallic = 0.8
		rim_mat.roughness = 0.2
		rim.material = rim_mat
		car_container.add_child(rim)
	
	return car_container

func create_parked_cars():
	var colors = [
		Color(0.85, 0.12, 0.12, 1),    # Red
		Color(0.1, 0.25, 0.75, 1),     # Blue
		Color(0.92, 0.92, 0.92, 1),    # White
		Color(0.08, 0.08, 0.08, 1),    # Black
		Color(0.68, 0.68, 0.72, 1),    # Silver
		Color(0.22, 0.65, 0.22, 1),    # Green
		Color(0.75, 0.32, 0.12, 1)     # Orange
	]
	
	var positions = [
		-30, -20, -10, 0, 10, 20, 30
	]
	
	for i in range(7):
		var car = create_car_model(colors[i], Vector3(positions[i], 0.0, 58), 0)
		add_child(car)
