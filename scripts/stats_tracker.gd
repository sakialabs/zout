class_name StatsTracker
extends Node

## Tracks session statistics and achievements
## Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5

# Preload SessionStats class
const SessionStats = preload("res://scripts/session_stats.gd")

# Session statistics
var session_stats: SessionStats

# Signals for stat updates
signal stats_updated(stats: Dictionary)
signal goal_streak_updated(current: int, best: int)


func _ready() -> void:
	# Initialize session stats
	session_stats = SessionStats.new()


## Record a new attempt
## Validates: Requirements 8.1
func record_attempt() -> void:
	session_stats.record_attempt()
	stats_updated.emit(get_stats())


## Record a successful goal
## Validates: Requirements 8.1, 8.2, 8.3, 8.4
func record_goal(is_top_bins: bool, points: int) -> void:
	session_stats.record_goal(is_top_bins, points)
	goal_streak_updated.emit(session_stats.current_streak, session_stats.best_streak)
	stats_updated.emit(get_stats())


## Record a miss and reset current streak
## Validates: Requirements 8.3
func record_miss() -> void:
	session_stats.record_miss()
	goal_streak_updated.emit(session_stats.current_streak, session_stats.best_streak)
	stats_updated.emit(get_stats())


## Get all statistics as a dictionary
## Validates: Requirements 8.5
func get_stats() -> Dictionary:
	return session_stats.get_stats()


## Reset all session statistics
## Validates: Requirements 8.5
func reset_session() -> void:
	session_stats.reset_session()
	stats_updated.emit(get_stats())
