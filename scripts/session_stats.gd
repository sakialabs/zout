class_name SessionStats
extends RefCounted

## Complete session statistics with tracking and calculation methods
## Validates: Requirements 8.1, 8.2, 8.3, 8.4

const MAX_STAT_VALUE: int = 999999

var total_attempts: int = 0
var total_goals: int = 0
var top_bins_count: int = 0
var current_streak: int = 0
var best_streak: int = 0
var total_score: int = 0


## Calculate accuracy percentage
func get_accuracy() -> float:
	if total_attempts > 0:
		return (float(total_goals) / float(total_attempts)) * 100.0
	return 0.0


## Calculate Top Bins rate percentage
func get_top_bins_rate() -> float:
	if total_goals > 0:
		return (float(top_bins_count) / float(total_goals)) * 100.0
	return 0.0


## Record a new attempt
func record_attempt() -> void:
	total_attempts = mini(total_attempts + 1, MAX_STAT_VALUE)


## Record a successful goal
func record_goal(is_top_bins: bool, points: int) -> void:
	total_goals = mini(total_goals + 1, MAX_STAT_VALUE)
	current_streak = mini(current_streak + 1, MAX_STAT_VALUE)
	
	if current_streak > best_streak:
		best_streak = current_streak
	
	if is_top_bins:
		top_bins_count = mini(top_bins_count + 1, MAX_STAT_VALUE)
	
	total_score = mini(total_score + points, MAX_STAT_VALUE)


## Record a miss and reset current streak
func record_miss() -> void:
	current_streak = 0


## Reset all session statistics
func reset_session() -> void:
	total_attempts = 0
	total_goals = 0
	top_bins_count = 0
	current_streak = 0
	best_streak = 0
	total_score = 0


## Get all statistics as a dictionary
func get_stats() -> Dictionary:
	return {
		"total_attempts": total_attempts,
		"total_goals": total_goals,
		"top_bins_count": top_bins_count,
		"current_streak": current_streak,
		"best_streak": best_streak,
		"total_score": total_score,
		"accuracy": get_accuracy(),
		"top_bins_rate": get_top_bins_rate()
	}
