extends Node3D

var cars = []
var car_speed = 3.0  # Slow speed for background traffic

func _ready():
	print("🚗 Moving cars script started")
	create_moving_cars()
	print("✅ Created ", cars.size(), " moving vehicles")

func create_school_bus(position: Vector3, direction: int) -> Node3D:
	var bus_container = Node3D.new()
	bus_container.position = position
	
	# Bus body (much larger and taller)
	var body = CSGBox3D.new()
	body.size = Vector3(7.0, 2.8, 2.2)
	body.position = Vector3(0, 1.4, 0)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.95, 0.75, 0.1, 1)  # Yellow
	body_mat.metallic = 0.5
	body_mat.roughness = 0.3
	body.material = body_mat
	bus_container.add_child(body)
	
	# Black stripe
	var stripe = CSGBox3D.new()
	stripe.size = Vector3(6.8, 0.3, 2.25)
	stripe.position = Vector3(0, 1.8, 0)
	var stripe_mat = StandardMaterial3D.new()
	stripe_mat.albedo_color = Color(0.05, 0.05, 0.05, 1)
	stripe.material = stripe_mat
	bus_container.add_child(stripe)
	
	# Windows (many)
	var window_mat = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.08, 0.1, 0.15, 0.7)
	window_mat.metallic = 0.9
	window_mat.roughness = 0.05
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Multiple side windows
	for i in range(5):
		var window = CSGBox3D.new()
		window.size = Vector3(1.0, 0.8, 0.08)
		window.position = Vector3(-2.5 + i * 1.3, 1.9, 1.13)
		window.material = window_mat
		bus_container.add_child(window)
	
	# Front windshield
	var front_window = CSGBox3D.new()
	front_window.size = Vector3(0.08, 1.2, 1.8)
	front_window.position = Vector3(3.4, 2.0, 0)
	front_window.material = window_mat
	bus_container.add_child(front_window)
	
	# Tires (bigger for bus)
	var tire_mat = StandardMaterial3D.new()
	tire_mat.albedo_color = Color(0.08, 0.08, 0.08, 1)
	tire_mat.roughness = 0.85
	
	var tire_positions = [
		Vector3(2.5, 0.5, -1.2),
		Vector3(2.5, 0.5, 1.2),
		Vector3(-2.5, 0.5, -1.2),
		Vector3(-2.5, 0.5, 1.2)
	]
	
	for tire_pos in tire_positions:
		var tire = CSGCylinder3D.new()
		tire.radius = 0.5
		tire.height = 0.3
		tire.sides = 16
		tire.position = tire_pos
		tire.rotation_degrees = Vector3(0, 0, 90)
		tire.material = tire_mat
		bus_container.add_child(tire)
	
	bus_container.set_meta("direction", direction)
	bus_container.set_meta("speed", car_speed * 0.8)  # Slower
	
	if direction < 0:
		bus_container.rotation_degrees.y = 180
	
	return bus_container

func create_suv_model(color: Color, position: Vector3, direction: int) -> Node3D:
	var suv_container = Node3D.new()
	suv_container.position = position
	
	# SUV body (taller and boxier)
	var body = CSGBox3D.new()
	body.size = Vector3(3.8, 1.6, 1.9)
	body.position = Vector3(0, 0.8, 0)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = color
	body_mat.metallic = 0.75
	body_mat.roughness = 0.15
	body.material = body_mat
	suv_container.add_child(body)
	
	# Cabin (taller for SUV)
	var cabin = CSGBox3D.new()
	cabin.size = Vector3(2.5, 1.0, 1.7)
	cabin.position = Vector3(-0.3, 1.85, 0)
	cabin.material = body_mat
	suv_container.add_child(cabin)
	
	# Windows
	var window_mat = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.08, 0.1, 0.15, 0.65)
	window_mat.metallic = 0.95
	window_mat.roughness = 0.05
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var front_window = CSGBox3D.new()
	front_window.size = Vector3(0.08, 0.8, 1.6)
	front_window.position = Vector3(0.9, 1.85, 0)
	front_window.material = window_mat
	suv_container.add_child(front_window)
	
	# Tires (larger for SUV)
	var tire_mat = StandardMaterial3D.new()
	tire_mat.albedo_color = Color(0.08, 0.08, 0.08, 1)
	tire_mat.roughness = 0.85
	
	var tire_positions = [
		Vector3(1.3, 0.45, -1.0),
		Vector3(1.3, 0.45, 1.0),
		Vector3(-1.3, 0.45, -1.0),
		Vector3(-1.3, 0.45, 1.0)
	]
	
	for tire_pos in tire_positions:
		var tire = CSGCylinder3D.new()
		tire.radius = 0.45
		tire.height = 0.3
		tire.sides = 16
		tire.position = tire_pos
		tire.rotation_degrees = Vector3(0, 0, 90)
		tire.material = tire_mat
		suv_container.add_child(tire)
		
		var rim = CSGCylinder3D.new()
		rim.radius = 0.25
		rim.height = 0.32
		rim.sides = 12
		rim.position = tire_pos
		rim.rotation_degrees = Vector3(0, 0, 90)
		var rim_mat = StandardMaterial3D.new()
		rim_mat.albedo_color = Color(0.5, 0.5, 0.55, 1)
		rim_mat.metallic = 0.8
		rim_mat.roughness = 0.2
		rim.material = rim_mat
		suv_container.add_child(rim)
	
	suv_container.set_meta("direction", direction)
	suv_container.set_meta("speed", car_speed)
	
	if direction < 0:
		suv_container.rotation_degrees.y = 180
	
	return suv_container

func create_car_model(color: Color, position: Vector3, direction: int) -> Node3D:
	var car_container = Node3D.new()
	car_container.position = position
	
	# Car body (main chassis) - more elongated car shape
	var body = CSGBox3D.new()
	body.size = Vector3(3.2, 1.0, 1.6)
	body.position = Vector3(0, 0.5, 0)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = color
	body_mat.metallic = 0.75
	body_mat.roughness = 0.15
	body.material = body_mat
	car_container.add_child(body)
	
	# Car cabin/roof (smaller upper part)
	var cabin = CSGBox3D.new()
	cabin.size = Vector3(1.8, 0.75, 1.4)
	cabin.position = Vector3(-0.3, 1.375, 0)
	cabin.material = body_mat
	car_container.add_child(cabin)
	
	# Hood (front sloped part)
	var hood = CSGBox3D.new()
	hood.size = Vector3(0.9, 0.6, 1.6)
	hood.position = Vector3(1.5, 0.6, 0)
	hood.material = body_mat
	car_container.add_child(hood)
	
	# Windows (dark glass)
	var window_mat = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.08, 0.1, 0.15, 0.65)
	window_mat.metallic = 0.95
	window_mat.roughness = 0.05
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Front windshield
	var front_window = CSGBox3D.new()
	front_window.size = Vector3(0.08, 0.6, 1.3)
	front_window.position = Vector3(0.55, 1.375, 0)
	front_window.material = window_mat
	car_container.add_child(front_window)
	
	# Rear windshield
	var rear_window = CSGBox3D.new()
	rear_window.size = Vector3(0.08, 0.6, 1.3)
	rear_window.position = Vector3(-1.1, 1.375, 0)
	rear_window.material = window_mat
	car_container.add_child(rear_window)
	
	# Side windows (left and right)
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
	
	# Tires/Wheels (4 black cylinders)
	var tire_mat = StandardMaterial3D.new()
	tire_mat.albedo_color = Color(0.08, 0.08, 0.08, 1)
	tire_mat.roughness = 0.85
	
	var tire_positions = [
		Vector3(1.1, 0.35, -0.85),   # Front left
		Vector3(1.1, 0.35, 0.85),    # Front right
		Vector3(-1.1, 0.35, -0.85),  # Rear left
		Vector3(-1.1, 0.35, 0.85)    # Rear right
	]
	
	for tire_pos in tire_positions:
		# Main tire
		var tire = CSGCylinder3D.new()
		tire.radius = 0.35
		tire.height = 0.25
		tire.sides = 16
		tire.position = tire_pos
		tire.rotation_degrees = Vector3(0, 0, 90)
		tire.material = tire_mat
		car_container.add_child(tire)
		
		# Rim (lighter center part)
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
	
	# Headlights
	var headlight_mat = StandardMaterial3D.new()
	headlight_mat.albedo_color = Color(0.95, 0.95, 0.85, 1)
	headlight_mat.emission_enabled = true
	headlight_mat.emission = Color(1, 1, 0.9, 1)
	headlight_mat.emission_energy_multiplier = 0.8
	headlight_mat.metallic = 0.7
	headlight_mat.roughness = 0.1
	
	var headlight_left = CSGSphere3D.new()
	headlight_left.radius = 0.12
	headlight_left.radial_segments = 8
	headlight_left.rings = 6
	headlight_left.position = Vector3(1.9, 0.55, -0.5)
	headlight_left.material = headlight_mat
	car_container.add_child(headlight_left)
	
	var headlight_right = CSGSphere3D.new()
	headlight_right.radius = 0.12
	headlight_right.radial_segments = 8
	headlight_right.rings = 6
	headlight_right.position = Vector3(1.9, 0.55, 0.5)
	headlight_right.material = headlight_mat
	car_container.add_child(headlight_right)
	
	# Store direction for movement
	car_container.set_meta("direction", direction)
	car_container.set_meta("speed", car_speed)
	
	# Flip car if moving right to left
	if direction < 0:
		car_container.rotation_degrees.y = 180
	
	return car_container

func create_moving_cars():
	var colors = [
		Color(0.85, 0.12, 0.12, 1),    # Red
		Color(0.1, 0.25, 0.75, 1),     # Blue
		Color(0.92, 0.92, 0.92, 1),    # White
		Color(0.08, 0.08, 0.08, 1),    # Black
		Color(0.68, 0.68, 0.72, 1),    # Silver
		Color(0.22, 0.65, 0.22, 1),    # Green
		Color(0.15, 0.45, 0.72, 1),    # Light Blue
		Color(0.52, 0.27, 0.12, 1)     # Brown
	]
	
	var vehicle_index = 0
	
	# Create 15 vehicles - mix of cars, SUVs, and a school bus
	for i in range(15):
		var direction = 1 if i < 8 else -1
		var lane_z = 61.3 if direction > 0 else 64.7
		var start_x = -85 - (vehicle_index * 20) if direction > 0 else 85 + ((vehicle_index - 8) * 20)
		
		var vehicle
		
		# Add school bus (yellow) as vehicle 3
		if i == 3:
			vehicle = create_school_bus(Vector3(start_x, 0.0, lane_z), direction)
		# Add school bus going opposite direction too
		elif i == 11:
			vehicle = create_school_bus(Vector3(start_x, 0.0, lane_z), direction)
		# Every 3rd vehicle is an SUV
		elif i % 3 == 0:
			var color = colors[i % colors.size()]
			vehicle = create_suv_model(color, Vector3(start_x, 0.0, lane_z), direction)
		# Regular cars
		else:
			var color = colors[i % colors.size()]
			vehicle = create_car_model(color, Vector3(start_x, 0.0, lane_z), direction)
		
		add_child(vehicle)
		cars.append(vehicle)
		vehicle_index += 1

func _process(delta):
	# Move cars based on their direction
	for car in cars:
		var direction = car.get_meta("direction")
		var speed = car.get_meta("speed")
		
		car.position.x += direction * speed * delta
		
		# Reset position when off screen
		if direction > 0 and car.position.x > 85:
			car.position.x = -85
		elif direction < 0 and car.position.x < -85:
			car.position.x = 85
