extends Node

## Test script for StatsTracker functionality
## Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5

# Preload required classes
const StatsTracker = preload("res://scripts/stats_tracker.gd")

func _ready():
	print("\n=== STATS TRACKER TEST ===\n")
	
	# Create StatsTracker instance
	var stats_tracker = StatsTracker.new()
	add_child(stats_tracker)
	
	# Test 1: Initial state
	print("Test 1: Initial state")
	var initial_stats = stats_tracker.get_stats()
	assert(initial_stats["total_attempts"] == 0, "Initial attempts should be 0")
	assert(initial_stats["total_goals"] == 0, "Initial goals should be 0")
	assert(initial_stats["total_score"] == 0, "Initial score should be 0")
	print("  ✓ Initial state correct\n")
	
	# Test 2: Record attempts and goals
	print("Test 2: Record attempts and goals")
	stats_tracker.record_attempt()
	stats_tracker.record_goal(false, 100)  # Regular goal
	
	stats_tracker.record_attempt()
	stats_tracker.record_goal(true, 150)   # Top Bins goal
	
	stats_tracker.record_attempt()
	stats_tracker.record_miss()            # Miss
	
	var stats = stats_tracker.get_stats()
	assert(stats["total_attempts"] == 3, "Should have 3 attempts")
	assert(stats["total_goals"] == 2, "Should have 2 goals")
	assert(stats["top_bins_count"] == 1, "Should have 1 Top Bins")
	assert(stats["current_streak"] == 0, "Current streak should be 0 after miss")
	assert(stats["best_streak"] == 2, "Best streak should be 2")
	assert(stats["total_score"] == 250, "Total score should be 250")
	print("  ✓ Attempt and goal tracking correct\n")
	
	# Test 3: Accuracy calculation
	print("Test 3: Accuracy calculation")
	var accuracy = stats["accuracy"]
	var expected_accuracy = (2.0 / 3.0) * 100.0  # 66.67%
	assert(abs(accuracy - expected_accuracy) < 0.1, "Accuracy should be ~66.67%")
	print("  ✓ Accuracy calculation correct: ", snappedf(accuracy, 0.01), "%\n")
	
	# Test 4: Top Bins rate calculation
	print("Test 4: Top Bins rate calculation")
	var top_bins_rate = stats["top_bins_rate"]
	var expected_rate = (1.0 / 2.0) * 100.0  # 50%
	assert(abs(top_bins_rate - expected_rate) < 0.1, "Top Bins rate should be 50%")
	print("  ✓ Top Bins rate correct: ", snappedf(top_bins_rate, 0.01), "%\n")
	
	# Test 5: Streak tracking
	print("Test 5: Streak tracking")
	stats_tracker.record_attempt()
	stats_tracker.record_goal(false, 100)
	
	stats_tracker.record_attempt()
	stats_tracker.record_goal(false, 100)
	
	stats_tracker.record_attempt()
	stats_tracker.record_goal(true, 150)
	
	stats = stats_tracker.get_stats()
	assert(stats["current_streak"] == 3, "Current streak should be 3")
	assert(stats["best_streak"] == 3, "Best streak should be updated to 3")
	print("  ✓ Streak tracking correct\n")
	
	# Test 6: Reset session
	print("Test 6: Reset session")
	stats_tracker.reset_session()
	stats = stats_tracker.get_stats()
	assert(stats["total_attempts"] == 0, "Attempts should be reset to 0")
	assert(stats["total_goals"] == 0, "Goals should be reset to 0")
	assert(stats["total_score"] == 0, "Score should be reset to 0")
	assert(stats["current_streak"] == 0, "Current streak should be reset to 0")
	assert(stats["best_streak"] == 0, "Best streak should be reset to 0")
	print("  ✓ Session reset correct\n")
	
	# Test 7: Overflow protection
	print("Test 7: Overflow protection")
	for i in range(1000000):
		stats_tracker.record_attempt()
	stats = stats_tracker.get_stats()
	assert(stats["total_attempts"] == 999999, "Should cap at 999,999")
	print("  ✓ Overflow protection works\n")
	
	print("=== ALL TESTS PASSED ===\n")
	
	# Exit after tests
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
