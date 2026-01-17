extends Node3D

## Main Practice Mode - Basic Strike Mechanics
## WASD to aim, SPACE to kick

@onready var ball = $Ball
@onready var camera: Camera3D = $Camera3D
@onready var goal = $Goal
@onready var goal_net = $Goal/Net

var ball_start_position: Vector3 = Vector3(0, 0.3, -20)  # Ball on ground (y = radius)
var aim_direction: Vector3 = Vector3(0, 0, 1)  # Point toward goal (positive Z)
var power: float = 0.0
var is_charging: bool = false
var can_strike: bool = true
var goal_scored_flag: bool = false  # Prevent multiple goal triggers

# UI Label for on-screen ZOUT message
var zout_label: Label

const CHARGE_SPEED: float = 0.8  # Power charges to 100% in ~1.25 seconds
const MAX_POWER: float = 35.0  # Maximum strike force
const AIM_SPEED: float = 2.0


func _ready():
	print("\n=== ZOUT - PRACTICE MODE ===")
	print("⚽ Feel the strike\n")
	
	# Create ZOUT label with custom theme to force white color
	zout_label = Label.new()
	zout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zout_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	# Force white color with custom theme
	var custom_theme = Theme.new()
	custom_theme.set_color("font_color", "Label", Color.WHITE)
	custom_theme.set_color("font_outline_color", "Label", Color.BLACK)
	custom_theme.set_constant("outline_size", "Label", 18)
	custom_theme.set_constant("shadow_offset_x", "Label", 6)
	custom_theme.set_constant("shadow_offset_y", "Label", 6)
	custom_theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.8))
	
	# Create font variation for size
	var font_variation = SystemFont.new()
	font_variation.font_names = ["Arial", "Helvetica", "Sans"]
	custom_theme.set_font("font", "Label", font_variation)
	custom_theme.set_font_size("font_size", "Label", 200)
	
	zout_label.theme = custom_theme
	zout_label.modulate = Color.WHITE  # Extra insurance
	zout_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zout_label.visible = false
	zout_label.anchor_left = 0.0
	zout_label.anchor_right = 1.0
	zout_label.anchor_top = 0.0
	zout_label.anchor_bottom = 0.3
	add_child(zout_label)
	
	# Position ball at start
	if ball:
		ball.global_position = ball_start_position
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO
		print("✓ Ball ready")
	
	# Position camera (behind ball looking toward goal)
	if camera:
		camera.global_position = Vector3(0, 3, -25)
		camera.look_at(Vector3(0, 1, 10), Vector3.UP)
		print("✓ Camera positioned")
	
	# Connect goal detection
	if goal:
		goal.body_entered.connect(_on_goal_scored)
		print("✓ Goal detector ready")
	
	# Allow multiple goal detections with monitoring
	goal_scored_flag = false
	
	print("\nControls:")
	print("  WASD - Aim")
	print("  SPACE - Hold to charge, release to strike")
	print("  R - Reset ball")
	print("  ESC - Main menu\n")


func _on_goal_scored(body):
	"""Detect when ball enters goal"""
	if body == ball and not goal_scored_flag:
		goal_scored_flag = true  # Prevent multiple triggers
		
		print("\n🎉 ⚽ ZOUT! ⚽ 🎉")
		print("GOAL SCORED!\n")
		
		# Trigger net physics effect
		if goal_net and goal_net.has_method("trigger_net_effect"):
			var impact_point = ball.global_position
			goal_net.trigger_net_effect(ball, impact_point)
		
		# Animate ZOUT sliding down from sky!
		if zout_label:
			zout_label.text = "ZOUT!"
			zout_label.visible = true
			zout_label.modulate = Color(1.0, 0.85, 0.0, 0)  # Start transparent
			zout_label.position.y = -200  # Start above screen
			zout_label.rotation_degrees = -15
			
			# Slide down + fade in + straighten
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(zout_label, "modulate:a", 1.0, 0.4)
			tween.tween_property(zout_label, "position:y", 0, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(zout_label, "rotation_degrees", 0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			# Hold
			await tween.finished
			await get_tree().create_timer(1.2).timeout
			
			# Slide up and fade
			var tween2 = create_tween()
			tween2.set_parallel(true)
			tween2.tween_property(zout_label, "position:y", -200, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween2.tween_property(zout_label, "modulate:a", 0.0, 0.4)
			await tween2.finished
			zout_label.visible = false
		
		reset_ball()


func _process(delta: float):
	# ESC returns to menu
	if Input.is_action_just_pressed("ui_cancel"):
		print("Returning to main menu...")
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	# Reset ball with R
	if Input.is_action_just_pressed("reset"):  # R key - use correct action
		reset_ball()
		return
	
	if not can_strike:
		return
	
	# Aiming with WASD - use correct custom actions
	var aim_input := Vector2.ZERO
	if Input.is_action_pressed("aim_up"):  # W
		aim_input.y += 1
	if Input.is_action_pressed("aim_down"):  # S
		aim_input.y -= 1
	if Input.is_action_pressed("aim_left"):  # A
		aim_input.x -= 1
	if Input.is_action_pressed("aim_right"):  # D
		aim_input.x += 1
	
	if aim_input.length() > 0:
		aim_input = aim_input.normalized()
		aim_direction.x = lerp(aim_direction.x, aim_input.x * 0.5, AIM_SPEED * delta)
		aim_direction.z = lerp(aim_direction.z, 1.0, AIM_SPEED * delta)  # Always forward
		aim_direction = aim_direction.normalized()
	
	# Power charging with SPACE - use correct action
	if Input.is_action_pressed("power_charge"):  # SPACE
		if not is_charging:
			is_charging = true
			power = 0.0
			print("⚡ Charging...")
		
		power = min(power + CHARGE_SPEED * delta, 1.0)
	
	elif is_charging:
		# Released - strike!
		execute_strike()
		is_charging = false


func execute_strike():
	"""Strike the ball with current power and aim"""
	if not ball or not can_strike:
		return
	
	var strike_force = power * MAX_POWER
	var strike_vector = aim_direction * strike_force
	
	# Apply upward component for realistic trajectory
	strike_vector.y = strike_force * 0.4
	
	ball.linear_velocity = Vector3.ZERO
	ball.apply_central_impulse(strike_vector)
	
	var power_percent = int(power * 100)
	print("\n💥 STRIKE! Power: ", power_percent, "%")
	print("   Direction: ", aim_direction)
	
	can_strike = false
	
	# Auto-reset after 3 seconds
	await get_tree().create_timer(3.0).timeout
	reset_ball()


func reset_ball():
	"""Reset ball to starting position"""
	if ball:
		ball.global_position = ball_start_position
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO
		print("\n🔄 Ball reset - ready to strike\n")
	
	power = 0.0
	is_charging = false
	can_strike = true
	goal_scored_flag = false  # Reset goal flag
	aim_direction = Vector3(0, 0, 1)  # Point toward goal

