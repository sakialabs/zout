class_name OutcomeData
extends RefCounted

## Encapsulates the result of a strike
## Validates: Requirements 3.1, 4.1, 5.1

var is_goal: bool
var is_top_bins: bool
var entry_position: Vector3
var points_awarded: int
var strike_data: StrikeData


func _init(goal: bool, top_bins: bool, position: Vector3, points: int, strike: StrikeData) -> void:
	is_goal = goal
	is_top_bins = top_bins
	entry_position = position
	points_awarded = points
	strike_data = strike
