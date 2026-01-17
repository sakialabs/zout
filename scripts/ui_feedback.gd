class_name UIFeedback
extends Control

## Manages on-screen UI elements and score display
## Validates: Requirements 5.4, 9.4

# UI element references
var power_bar: ProgressBar
var score_label: Label
var stats_panel: Panel
var stats_label: Label
var stats_panel_visible: bool = false

# Score popup timing (Task 24 - Tuned for clean presentation)
var score_popup_timer: float = 0.0
var score_fade_timer: float = 0.0
var is_score_visible: bool = false
const SCORE_DELAY: float = 0.25  # Quick delay - just enough to not overlap with Zout
const SCORE_FADE_DURATION: float = 1.2  # Brief display, then fade - no UI spam


func _ready() -> void:
	# Create power bar
	power_bar = ProgressBar.new()
	power_bar.name = "PowerBar"
	power_bar.min_value = 0.0
	power_bar.max_value = 100.0
	power_bar.value = 0.0
	power_bar.show_percentage = false
	power_bar.size = Vector2(200, 20)
	power_bar.position = Vector2(20, 20)
	add_child(power_bar)
	
	# Style power bar (Task 24 - Minimal, clean design)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.8)  # Darker background
	style_box.border_width_left = 1
	style_box.border_width_right = 1
	style_box.border_width_top = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color(0.8, 0.8, 0.8, 0.6)  # Subtle border
	style_box.corner_radius_top_left = 2
	style_box.corner_radius_top_right = 2
	style_box.corner_radius_bottom_left = 2
	style_box.corner_radius_bottom_right = 2
	power_bar.add_theme_stylebox_override("background", style_box)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.9, 0.2, 0.95)  # Vibrant green fill
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2
	power_bar.add_theme_stylebox_override("fill", fill_style)
	
	# Create score label
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 48)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	score_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	score_label.add_theme_constant_override("outline_size", 4)
	score_label.visible = false
	add_child(score_label)
	
	# Position score label at center of screen
	_update_score_label_position()
	
	# Create stats panel
	stats_panel = Panel.new()
	stats_panel.name = "StatsPanel"
	stats_panel.size = Vector2(300, 250)
	stats_panel.position = Vector2(20, 60)  # Below power bar
	add_child(stats_panel)
	
	# Style stats panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1, 1, 1, 0.6)
	panel_style.corner_radius_top_left = 5
	panel_style.corner_radius_top_right = 5
	panel_style.corner_radius_bottom_left = 5
	panel_style.corner_radius_bottom_right = 5
	stats_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Create stats label
	stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.position = Vector2(10, 10)
	stats_label.size = Vector2(280, 230)
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	stats_panel.add_child(stats_label)
	
	# Hide stats panel initially
	stats_panel.visible = false
	
	# Hide power bar initially
	power_bar.visible = false


func _process(delta: float) -> void:
	# Handle score popup timing
	if is_score_visible:
		score_fade_timer += delta
		
		# Fade out after duration
		if score_fade_timer >= SCORE_FADE_DURATION:
			var fade_progress = (score_fade_timer - SCORE_FADE_DURATION) / 0.5  # 0.5s fade
			var alpha = 1.0 - clamp(fade_progress, 0.0, 1.0)
			score_label.modulate = Color(1, 1, 1, alpha)
			
			# Hide completely after fade
			if alpha <= 0.0:
				score_label.visible = false
				is_score_visible = false
				score_label.modulate = Color(1, 1, 1, 1)  # Reset alpha


func _notification(what: int) -> void:
	# Update score label position on viewport resize
	if what == NOTIFICATION_RESIZED:
		_update_score_label_position()


## Update power bar to show current power level
## Validates: Requirements 5.4
func update_power_bar(power: float) -> void:
	if power_bar:
		power_bar.value = power * 100.0
		power_bar.visible = true


## Show score popup with delay after Zout
## Validates: Requirements 5.4
func show_score_popup(points: int) -> void:
	# Start delay timer
	await get_tree().create_timer(SCORE_DELAY).timeout
	
	# Display score
	if score_label:
		score_label.text = "+" + str(points)
		score_label.visible = true
		score_label.modulate = Color(1, 1, 1, 1)  # Reset alpha
		is_score_visible = true
		score_fade_timer = 0.0


## Hide all UI elements for clean Zout moments
## Validates: Requirements 9.4
func hide_all_ui() -> void:
	if power_bar:
		power_bar.visible = false
	
	if score_label:
		score_label.visible = false
		is_score_visible = false
	
	# Don't hide stats panel if it's toggled on
	# Stats panel stays visible when user wants it


## Show power bar (called when charging starts)
func show_power_bar() -> void:
	if power_bar:
		power_bar.visible = true
		power_bar.value = 0.0


## Toggle stats panel visibility
## Validates: Requirements 8.5
func toggle_stats_panel() -> void:
	stats_panel_visible = not stats_panel_visible
	if stats_panel:
		stats_panel.visible = stats_panel_visible


## Show session statistics
## Validates: Requirements 8.5
func show_stats(stats: Dictionary) -> void:
	if stats_label and stats_panel_visible:
		var text = "SESSION STATS\n\n"
		text += "Attempts: " + str(stats.get("total_attempts", 0)) + "\n"
		text += "Goals: " + str(stats.get("total_goals", 0)) + "\n"
		text += "Top Bins: " + str(stats.get("top_bins_count", 0)) + "\n"
		text += "Accuracy: " + str(snappedf(stats.get("accuracy", 0.0), 0.1)) + "%\n"
		text += "Top Bins Rate: " + str(snappedf(stats.get("top_bins_rate", 0.0), 0.1)) + "%\n"
		text += "\n"
		text += "Current Streak: " + str(stats.get("current_streak", 0)) + "\n"
		text += "Best Streak: " + str(stats.get("best_streak", 0)) + "\n"
		text += "\n"
		text += "Total Score: " + str(stats.get("total_score", 0))
		
		stats_label.text = text


## Update score label position to center of screen
func _update_score_label_position() -> void:
	if score_label:
		var viewport_size = get_viewport_rect().size
		score_label.position = Vector2(
			(viewport_size.x - 200) / 2,  # Center horizontally (assuming ~200px width)
			viewport_size.y * 0.3  # Upper third of screen
		)
		score_label.size = Vector2(200, 60)
