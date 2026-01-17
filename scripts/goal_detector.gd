class_name GoalDetector
extends Area3D

## Goal detection and Top Bins zone checking
## Validates: Requirements 3.1, 3.2, 4.1, 4.5

# Goal dimensions (regulation size)
const GOAL_WIDTH: float = 7.32   # meters
const GOAL_HEIGHT: float = 2.44  # meters

# Top Bins zone definitions
const TOP_BINS_HEIGHT_THRESHOLD: float = 0.25  # Upper 25% of goal height
const TOP_BINS_WIDTH_THRESHOLD: float = 0.30   # Outer 30% of goal width

# Calculated Top Bins boundaries
const TOP_BINS_MIN_HEIGHT: float = GOAL_HEIGHT * (1.0 - TOP_BINS_HEIGHT_THRESHOLD)  # 1.83m
const TOP_BINS_LEFT_MAX_WIDTH: float = GOAL_WIDTH * TOP_BINS_WIDTH_THRESHOLD        # 2.196m
const TOP_BINS_RIGHT_MIN_WIDTH: float = GOAL_WIDTH * (1.0 - TOP_BINS_WIDTH_THRESHOLD)  # 5.124m

# Signals
signal goal_scored(entry_position: Vector3, is_top_bins: bool)
signal ball_missed()

# Track last ball position for entry point calculation
var last_ball_position: Vector3 = Vector3.ZERO
var ball_reference: BallPhysics = null


func _ready() -> void:
	# Connect to body entered signal
	body_entered.connect(_on_ball_entered)
	
	# Set up collision layer/mask for ball detection
	collision_layer = 0
	collision_mask = 1  # Assuming ball is on layer 1
	
	# Enable monitoring
	monitoring = true
	monitorable = false


## Detect when ball crosses goal line
## body: The physics body that entered the goal area
func _on_ball_entered(body: Node3D) -> void:
	# Check if the body is the ball
	if body is BallPhysics:
		ball_reference = body
		
		# Get entry point where ball crossed goal line
		var entry_point = get_entry_point()
		
		# Check if entry point is within goal boundaries
		if is_within_goal_boundaries(entry_point):
			# Check for Top Bins
			var is_top_bins = check_top_bins(entry_point)
			
			# Emit goal scored signal
			goal_scored.emit(entry_point, is_top_bins)
		else:
			# Ball entered area but outside goal boundaries
			ball_missed.emit()


## Check if entry position qualifies as Top Bins
## entry_position: The position where ball crossed goal line (local coordinates)
## Returns: true if in Top Bins zone (upper 25% height AND outer 30% width)
func check_top_bins(entry_position: Vector3) -> bool:
	# Get local Y coordinate (height) and X coordinate (width)
	var height = entry_position.y
	var width_from_center = abs(entry_position.x)
	
	# Check height requirement: upper 25% (1.83m - 2.44m)
	var is_in_top_height = height >= TOP_BINS_MIN_HEIGHT and height <= GOAL_HEIGHT
	
	# Check width requirement: outer 30% from either side
	# Left side: 0 to 2.196m from center (negative X)
	# Right side: 5.124m to 7.32m from center (positive X)
	var is_in_outer_width = false
	
	if entry_position.x < 0:
		# Left side of goal
		is_in_outer_width = abs(entry_position.x) <= TOP_BINS_LEFT_MAX_WIDTH
	else:
		# Right side of goal
		is_in_outer_width = entry_position.x >= TOP_BINS_RIGHT_MIN_WIDTH
	
	# Top Bins requires BOTH conditions
	return is_in_top_height and is_in_outer_width


## Calculate exact position where ball crossed goal line
## Returns: Entry point in local coordinates relative to goal center
func get_entry_point() -> Vector3:
	if ball_reference == null:
		return Vector3.ZERO
	
	# Get ball's current position in goal's local space
	var ball_global_pos = ball_reference.global_position
	var entry_point_local = to_local(ball_global_pos)
	
	# Project onto goal plane (Z = 0 in local space)
	# This gives us the X, Y coordinates where ball crossed
	entry_point_local.z = 0.0
	
	return entry_point_local


## Check if entry point is within goal boundaries
## entry_position: Position in local coordinates
## Returns: true if within goal width and height
func is_within_goal_boundaries(entry_position: Vector3) -> bool:
	# Goal is centered at origin in local space
	# Width: -3.66m to +3.66m (total 7.32m)
	# Height: 0m to 2.44m
	
	var half_width = GOAL_WIDTH / 2.0
	
	var within_width = entry_position.x >= -half_width and entry_position.x <= half_width
	var within_height = entry_position.y >= 0.0 and entry_position.y <= GOAL_HEIGHT
	
	return within_width and within_height


func _physics_process(_delta: float) -> void:
	# Track ball position for entry point calculation
	if ball_reference != null:
		last_ball_position = ball_reference.global_position
