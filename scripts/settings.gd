extends Control

## Settings Scene
## Task 26: Implement basic settings
## Persistent settings with minimal UI following Zout's tone

# Scene paths
const MAIN_MENU_SCENE = "res://scenes/main_menu.tscn"

# Settings file path
const SETTINGS_FILE = "user://settings.cfg"

# UI elements
var title_label: Label
var sound_toggle: CheckButton
var aim_assist_toggle: CheckButton
var shot_preview_toggle: CheckButton
var back_button: Button

# Settings data
var settings: Dictionary = {
	"sound_enabled": true,
	"aim_assist_enabled": false,
	"shot_preview_enabled": false
}


func _ready() -> void:
	# Load saved settings
	_load_settings()
	
	# Create background
	var color_rect = ColorRect.new()
	color_rect.color = Color(0.05, 0.05, 0.05, 1)
	color_rect.size = get_viewport_rect().size
	color_rect.z_index = -1
	add_child(color_rect)
	
	# Create title label
	title_label = Label.new()
	title_label.text = "SETTINGS"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 80)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title_label.position = Vector2(get_viewport_rect().size.x / 2 - 250, 100)
	title_label.size = Vector2(500, 120)
	add_child(title_label)
	
	# Create settings container
	var settings_container = VBoxContainer.new()
	settings_container.position = Vector2(get_viewport_rect().size.x / 2 - 200, 300)
	settings_container.size = Vector2(400, 400)
	settings_container.add_theme_constant_override("separation", 30)
	add_child(settings_container)
	
	# Create Sound toggle
	sound_toggle = _create_setting_toggle("SOUND", settings["sound_enabled"])
	sound_toggle.toggled.connect(_on_sound_toggled)
	settings_container.add_child(sound_toggle)
	
	# Create Aim Assist toggle
	aim_assist_toggle = _create_setting_toggle("AIM ASSIST", settings["aim_assist_enabled"])
	aim_assist_toggle.toggled.connect(_on_aim_assist_toggled)
	settings_container.add_child(aim_assist_toggle)
	
	# Create Shot Preview toggle
	shot_preview_toggle = _create_setting_toggle("SHOT PREVIEW", settings["shot_preview_enabled"])
	shot_preview_toggle.toggled.connect(_on_shot_preview_toggled)
	settings_container.add_child(shot_preview_toggle)
	
	# Create Back button
	back_button = _create_back_button()
	back_button.pressed.connect(_on_back_pressed)
	back_button.position = Vector2(get_viewport_rect().size.x / 2 - 150, 700)
	add_child(back_button)
	
	print("\n=== ZOUT - SETTINGS ===")
	print("Configure your practice experience")
	print("Settings will persist between sessions")
	print("=======================\n")


## Create a styled toggle button for settings
func _create_setting_toggle(label_text: String, initial_value: bool) -> CheckButton:
	var check_button = CheckButton.new()
	check_button.text = label_text
	check_button.button_pressed = initial_value
	check_button.custom_minimum_size = Vector2(400, 60)
	
	# Styling
	check_button.add_theme_font_size_override("font_size", 28)
	check_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	check_button.add_theme_color_override("font_hover_color", Color(0.2, 0.9, 0.2, 1))
	
	return check_button


## Create styled back button
func _create_back_button() -> Button:
	var button = Button.new()
	button.text = "BACK"
	button.custom_minimum_size = Vector2(300, 60)
	
	# Minimal button styling
	button.add_theme_font_size_override("font_size", 32)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(0.2, 0.9, 0.2, 1))
	
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
	
	return button


## Handle sound toggle
func _on_sound_toggled(button_pressed: bool) -> void:
	settings["sound_enabled"] = button_pressed
	_save_settings()
	
	# Apply sound setting globally
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not button_pressed)
	
	print("Sound: ", "ON" if button_pressed else "OFF")


## Handle aim assist toggle
func _on_aim_assist_toggled(button_pressed: bool) -> void:
	settings["aim_assist_enabled"] = button_pressed
	_save_settings()
	print("Aim Assist: ", "ON" if button_pressed else "OFF")


## Handle shot preview toggle
func _on_shot_preview_toggled(button_pressed: bool) -> void:
	settings["shot_preview_enabled"] = button_pressed
	_save_settings()
	print("Shot Preview: ", "ON" if button_pressed else "OFF")


## Handle back button press
func _on_back_pressed() -> void:
	print("Returning to Main Menu...")
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


## Load settings from file
func _load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)
	
	if err == OK:
		# Load each setting with defaults
		settings["sound_enabled"] = config.get_value("audio", "sound_enabled", true)
		settings["aim_assist_enabled"] = config.get_value("assists", "aim_assist_enabled", false)
		settings["shot_preview_enabled"] = config.get_value("assists", "shot_preview_enabled", false)
		
		print("Settings loaded from: ", SETTINGS_FILE)
		
		# Apply sound setting
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not settings["sound_enabled"])
	else:
		print("No saved settings found, using defaults")


## Save settings to file
func _save_settings() -> void:
	var config = ConfigFile.new()
	
	# Save settings
	config.set_value("audio", "sound_enabled", settings["sound_enabled"])
	config.set_value("assists", "aim_assist_enabled", settings["aim_assist_enabled"])
	config.set_value("assists", "shot_preview_enabled", settings["shot_preview_enabled"])
	
	# Write to file
	var err = config.save(SETTINGS_FILE)
	
	if err == OK:
		print("Settings saved to: ", SETTINGS_FILE)
	else:
		push_error("Failed to save settings: ", err)


## Get current settings (called by other scenes)
static func get_settings() -> Dictionary:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)
	
	var loaded_settings = {
		"sound_enabled": true,
		"aim_assist_enabled": false,
		"shot_preview_enabled": false
	}
	
	if err == OK:
		loaded_settings["sound_enabled"] = config.get_value("audio", "sound_enabled", true)
		loaded_settings["aim_assist_enabled"] = config.get_value("assists", "aim_assist_enabled", false)
		loaded_settings["shot_preview_enabled"] = config.get_value("assists", "shot_preview_enabled", false)
	
	return loaded_settings
