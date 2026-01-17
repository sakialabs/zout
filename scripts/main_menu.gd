extends Control

## Main Menu Scene
## Task 25: Create basic main menu
## Minimal UI following Zout's tone: calm, confident, focused

# Scene paths
const PRACTICE_SCENE = "res://scenes/practice_mode.tscn"
const SETTINGS_SCENE = "res://scenes/settings.tscn"

# UI elements
var title_label: Label
var practice_button: Button
var settings_button: Button
var quit_button: Button


func _ready() -> void:
	# Set background color FIRST (and make it ignore mouse input)
	var color_rect = ColorRect.new()
	color_rect.color = Color(0.05, 0.05, 0.05, 1)
	color_rect.size = get_viewport_rect().size
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Critical: don't block button clicks
	color_rect.z_index = -1
	add_child(color_rect)
	
	# Create title label
	title_label = Label.new()
	title_label.text = "ZOUT"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 120)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Labels don't need mouse input
	add_child(title_label)
	
	# Position title at top center
	title_label.position = Vector2(get_viewport_rect().size.x / 2 - 200, 150)
	title_label.size = Vector2(400, 150)
	
	# Create button container for centered vertical layout
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(get_viewport_rect().size.x / 2 - 150, 400)
	button_container.size = Vector2(300, 300)
	button_container.add_theme_constant_override("separation", 20)
	add_child(button_container)
	
	# Create Practice button
	practice_button = _create_menu_button("PRACTICE")
	practice_button.pressed.connect(_on_practice_pressed)
	button_container.add_child(practice_button)
	
	# Create Settings button
	settings_button = _create_menu_button("SETTINGS")
	settings_button.pressed.connect(_on_settings_pressed)
	button_container.add_child(settings_button)
	
	# Create Quit button
	quit_button = _create_menu_button("QUIT")
	quit_button.pressed.connect(_on_quit_pressed)
	button_container.add_child(quit_button)
	
	print("\n=== ZOUT - MAIN MENU ===")
	print("Welcome to Zout Practice Mode")
	print("========================\n")


## Create a styled menu button following Zout's minimal design
func _create_menu_button(button_text: String) -> Button:
	var button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(300, 60)
	button.mouse_filter = Control.MOUSE_FILTER_STOP  # Ensure button receives mouse events
	button.focus_mode = Control.FOCUS_ALL  # Allow button to receive focus
	
	# Minimal button styling
	button.add_theme_font_size_override("font_size", 32)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(0.2, 0.9, 0.2, 1))
	button.add_theme_color_override("font_pressed_color", Color(0.2, 0.9, 0.2, 1))
	
	# Button background style
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.5, 0.5, 0.5, 0.8)
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.2, 0.2, 0.2, 1)
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	hover_style.border_width_bottom = 2
	hover_style.border_color = Color(0.2, 0.9, 0.2, 1)
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_left = 4
	hover_style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.1, 0.1, 0.1, 1)
	pressed_style.border_width_left = 2
	pressed_style.border_width_right = 2
	pressed_style.border_width_top = 2
	pressed_style.border_width_bottom = 2
	pressed_style.border_color = Color(0.2, 0.9, 0.2, 1)
	pressed_style.corner_radius_top_left = 4
	pressed_style.corner_radius_top_right = 4
	pressed_style.corner_radius_bottom_left = 4
	pressed_style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	return button


## Handle Practice button press
func _on_practice_pressed() -> void:
	print("Loading Practice Mode...")
	get_tree().change_scene_to_file(PRACTICE_SCENE)


## Handle Settings button press
func _on_settings_pressed() -> void:
	print("Loading Settings...")
	# Check if settings scene exists
	if ResourceLoader.exists(SETTINGS_SCENE):
		get_tree().change_scene_to_file(SETTINGS_SCENE)
	else:
		print("Settings scene not found - creating placeholder")
		# For now, just show a message
		push_warning("Settings not yet implemented")


## Handle Quit button press
func _on_quit_pressed() -> void:
	print("Quitting Zout...")
	get_tree().quit()
