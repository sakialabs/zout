extends Node3D

## Building Shadows System
## Adds simple light/shadow effect to all buildings
## Creates a darker side panel for each building to simulate shadow

func _ready():
	print("🏢 Adding shadows to buildings...")
	add_building_shadows()
	print("✅ Building shadows created")

func add_building_shadows():
	# Get the Buildings node from parent
	var buildings_node = get_parent().get_node_or_null("Buildings")
	if not buildings_node:
		print("⚠️ Buildings node not found")
		return
	
	# Process each building
	for child in buildings_node.get_children():
		if child is CSGBox3D and child.name.begins_with("Building"):
			add_shadow_to_building(child)

func add_shadow_to_building(building: CSGBox3D):
	var size = building.size
	
	# Get the building's base color
	var base_color = Color(0.75, 0.7, 0.65, 1.0)  # Default
	if building.material and building.material is StandardMaterial3D:
		base_color = building.material.albedo_color
	
	# Create shadow material - darker shade of same color (0.6x brightness)
	var shadow_mat = StandardMaterial3D.new()
	shadow_mat.albedo_color = Color(
		base_color.r * 0.6,
		base_color.g * 0.6,
		base_color.b * 0.6,
		1.0
	)
	shadow_mat.metallic = 0.0
	shadow_mat.roughness = 0.9
	
	# Create light material - brighter shade of same color (1.15x brightness)
	var light_mat = StandardMaterial3D.new()
	light_mat.albedo_color = Color(
		min(base_color.r * 1.15, 1.0),
		min(base_color.g * 1.15, 1.0),
		min(base_color.b * 1.15, 1.0),
		1.0
	)
	light_mat.metallic = 0.0
	light_mat.roughness = 0.85
	
	# Shadow panel - right side (darker shade)
	var shadow_panel = CSGBox3D.new()
	shadow_panel.name = "ShadowSide"
	shadow_panel.size = Vector3(0.06, size.y * 0.96, size.z * 0.98)
	shadow_panel.position = Vector3(size.x / 2 + 0.03, 0, 0)
	shadow_panel.material = shadow_mat
	shadow_panel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	building.add_child(shadow_panel)
	
	# Light panel - left side (brighter shade)
	var light_panel = CSGBox3D.new()
	light_panel.name = "LightSide"
	light_panel.size = Vector3(0.06, size.y * 0.96, size.z * 0.98)
	light_panel.position = Vector3(-size.x / 2 - 0.03, 0, 0)
	light_panel.material = light_mat
	light_panel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	building.add_child(light_panel)
