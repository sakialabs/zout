extends Node

## Core Systems Validation Script
## Validates that all core systems work independently
## Task 7: Checkpoint - Core systems validation

var validation_results: Dictionary = {}
var all_tests_passed: bool = true


func _ready() -> void:
	print("\n=== CORE SYSTEMS VALIDATION ===\n")
	
	# Run all validation tests
	validate_data_models()
	validate_contact_quality_calculator()
	validate_aim_system()
	validate_power_system()
	validate_timing_system()
	
	# Print summary
	print_summary()
	
	# Exit after validation
	get_tree().quit()


## Validate data models (StrikeData, OutcomeData, SessionStats)
func validate_data_models() -> void:
	print("Testing Data Models...")
	var passed = true
	
	# Test StrikeData
	var strike = StrikeData.new(
		Vector3.FORWARD,
		0.85,
		0.02,
		StrikeData.ContactQuality.CLEAN
	)
	
	if strike.aim_direction != Vector3.FORWARD:
		print("  ❌ StrikeData: aim_direction not preserved")
		passed = false
	elif strike.power_level != 0.85:
		print("  ❌ StrikeData: power_level not preserved")
		passed = false
	elif strike.timing_offset != 0.02:
		print("  ❌ StrikeData: timing_offset not preserved")
		passed = false
	elif strike.contact_quality != StrikeData.ContactQuality.CLEAN:
		print("  ❌ StrikeData: contact_quality not preserved")
		passed = false
	else:
		print("  ✓ StrikeData works correctly")
	
	# Test OutcomeData
	var outcome = OutcomeData.new(
		true,
		false,
		Vector3(0, 1, 10),
		100,
		strike
	)
	
	if not outcome.is_goal:
		print("  ❌ OutcomeData: is_goal not preserved")
		passed = false
	elif outcome.is_top_bins:
		print("  ❌ OutcomeData: is_top_bins not preserved")
		passed = false
	elif outcome.points_awarded != 100:
		print("  ❌ OutcomeData: points_awarded not preserved")
		passed = false
	else:
		print("  ✓ OutcomeData works correctly")
	
	# Test SessionStats
	var stats = SessionStats.new()
	stats.record_attempt()
	stats.record_goal(false, 100)
	stats.record_attempt()
	stats.record_goal(true, 150)
	stats.record_attempt()
	stats.record_miss()
	
	if stats.total_attempts != 3:
		print("  ❌ SessionStats: total_attempts incorrect (expected 3, got ", stats.total_attempts, ")")
		passed = false
	elif stats.total_goals != 2:
		print("  ❌ SessionStats: total_goals incorrect (expected 2, got ", stats.total_goals, ")")
		passed = false
	elif stats.top_bins_count != 1:
		print("  ❌ SessionStats: top_bins_count incorrect (expected 1, got ", stats.top_bins_count, ")")
		passed = false
	elif stats.current_streak != 0:
		print("  ❌ SessionStats: current_streak not reset after miss (expected 0, got ", stats.current_streak, ")")
		passed = false
	elif stats.best_streak != 2:
		print("  ❌ SessionStats: best_streak incorrect (expected 2, got ", stats.best_streak, ")")
		passed = false
	elif stats.total_score != 250:
		print("  ❌ SessionStats: total_score incorrect (expected 250, got ", stats.total_score, ")")
		passed = false
	elif abs(stats.get_accuracy() - 66.67) > 0.1:
		print("  ❌ SessionStats: accuracy calculation incorrect (expected ~66.67, got ", stats.get_accuracy(), ")")
		passed = false
	elif abs(stats.get_top_bins_rate() - 50.0) > 0.1:
		print("  ❌ SessionStats: top_bins_rate calculation incorrect (expected 50.0, got ", stats.get_top_bins_rate(), ")")
		passed = false
	else:
		print("  ✓ SessionStats works correctly")
	
	validation_results["Data Models"] = passed
	if not passed:
		all_tests_passed = false


## Validate ContactQualityCalculator
func validate_contact_quality_calculator() -> void:
	print("\nTesting ContactQualityCalculator...")
	var passed = true
	var calculator = ContactQualityCalculator.new()
	
	# Test perfect quality (optimal power + perfect timing)
	var quality = calculator.calculate_quality(0.95, 0.02)
	if quality != StrikeData.ContactQuality.PERFECT:
		print("  ❌ Perfect quality not detected (power: 0.95, offset: 0.02)")
		passed = false
	else:
		print("  ✓ Perfect quality detection works")
	
	# Test clean quality
	quality = calculator.calculate_quality(0.80, 0.10)
	if quality != StrikeData.ContactQuality.CLEAN:
		print("  ❌ Clean quality not detected (power: 0.80, offset: 0.10)")
		passed = false
	else:
		print("  ✓ Clean quality detection works")
	
	# Test okay quality
	quality = calculator.calculate_quality(0.70, 0.25)
	if quality != StrikeData.ContactQuality.OKAY:
		print("  ❌ Okay quality not detected (power: 0.70, offset: 0.25)")
		passed = false
	else:
		print("  ✓ Okay quality detection works")
	
	# Test scuffed quality (low power)
	quality = calculator.calculate_quality(0.15, 0.01)
	if quality != StrikeData.ContactQuality.SCUFFED:
		print("  ❌ Scuffed quality not detected for low power (power: 0.15)")
		passed = false
	else:
		print("  ✓ Scuffed quality detection works (low power)")
	
	# Test scuffed quality (bad timing)
	quality = calculator.calculate_quality(0.80, 0.40)
	if quality != StrikeData.ContactQuality.SCUFFED:
		print("  ❌ Scuffed quality not detected for bad timing (offset: 0.40)")
		passed = false
	else:
		print("  ✓ Scuffed quality detection works (bad timing)")
	
	# Test multipliers
	var multiplier = calculator.get_quality_multiplier(StrikeData.ContactQuality.PERFECT)
	if abs(multiplier - 1.25) > 0.001:
		print("  ❌ Perfect multiplier incorrect (expected 1.25, got ", multiplier, ")")
		passed = false
	else:
		print("  ✓ Quality multipliers work correctly")
	
	validation_results["ContactQualityCalculator"] = passed
	if not passed:
		all_tests_passed = false


## Validate AimSystem
func validate_aim_system() -> void:
	print("\nTesting AimSystem...")
	var passed = true
	var aim_system = AimSystem.new()
	
	# Test zero vector defaults to goal center
	aim_system.update_aim(Vector2.ZERO)
	var direction = aim_system.get_aim_direction()
	if not direction.is_equal_approx(Vector3.FORWARD):
		print("  ❌ Zero aim doesn't default to goal center (got ", direction, ")")
		passed = false
	else:
		print("  ✓ Zero aim defaults to goal center")
	
	# Test aim input updates
	aim_system.update_aim(Vector2(0.5, 0.3))
	if not aim_system.current_aim.is_equal_approx(Vector2(0.5, 0.3)):
		print("  ❌ Aim input not updated correctly")
		passed = false
	else:
		print("  ✓ Aim input updates correctly")
	
	# Test aim direction calculation
	direction = aim_system.get_aim_direction()
	if direction.length() < 0.99 or direction.length() > 1.01:
		print("  ❌ Aim direction not normalized (length: ", direction.length(), ")")
		passed = false
	else:
		print("  ✓ Aim direction is normalized")
	
	# Test aim clamping
	aim_system.update_aim(Vector2(2.0, -2.0))  # Out of bounds
	if aim_system.current_aim.x > 1.0 or aim_system.current_aim.y < -1.0:
		print("  ❌ Aim not clamped to valid range")
		passed = false
	else:
		print("  ✓ Aim clamping works correctly")
	
	# Test cone vertices generation
	var vertices = aim_system.get_aim_cone_vertices()
	if vertices.size() < 10:
		print("  ❌ Cone vertices not generated (got ", vertices.size(), " vertices)")
		passed = false
	else:
		print("  ✓ Cone vertices generated correctly")
	
	validation_results["AimSystem"] = passed
	if not passed:
		all_tests_passed = false


## Validate PowerSystem
func validate_power_system() -> void:
	print("\nTesting PowerSystem...")
	var passed = true
	var power_system = PowerSystem.new()
	
	# Test initial state
	if power_system.is_charging:
		print("  ❌ PowerSystem starts in charging state")
		passed = false
	else:
		print("  ✓ PowerSystem starts in correct state")
	
	# Test charge start
	power_system.start_charge()
	if not power_system.is_charging:
		print("  ❌ PowerSystem not charging after start_charge()")
		passed = false
	else:
		print("  ✓ Charge starts correctly")
	
	# Test power calculation (simulate time passing)
	await get_tree().create_timer(0.75).timeout  # Wait 0.75s (50% of 1.5s)
	var power = power_system.get_current_power()
	if power < 0.45 or power > 0.55:  # Allow some tolerance
		print("  ❌ Power calculation incorrect at 50% charge time (expected ~0.50, got ", power, ")")
		passed = false
	else:
		print("  ✓ Power calculation works correctly")
	
	# Test power release
	var final_power = power_system.release_charge()
	if power_system.is_charging:
		print("  ❌ PowerSystem still charging after release")
		passed = false
	elif final_power < 0.45 or final_power > 0.55:
		print("  ❌ Released power incorrect (expected ~0.50, got ", final_power, ")")
		passed = false
	else:
		print("  ✓ Power release works correctly")
	
	# Test minimum power threshold
	power_system.start_charge()
	await get_tree().create_timer(0.1).timeout  # Very short charge
	final_power = power_system.release_charge()
	if final_power != -1.0:
		print("  ❌ Low power not rejected (expected -1.0, got ", final_power, ")")
		passed = false
	else:
		print("  ✓ Minimum power threshold works correctly")
	
	validation_results["PowerSystem"] = passed
	if not passed:
		all_tests_passed = false


## Validate TimingSystem
func validate_timing_system() -> void:
	print("\nTesting TimingSystem...")
	var passed = true
	var power_system = PowerSystem.new()
	var timing_system = TimingSystem.new(power_system)
	
	# Test timing offset calculation
	var charge_start = 0.0
	var release_time = 1.425  # 95% of 1.5s (optimal timing)
	var offset = timing_system.get_timing_offset(release_time, charge_start)
	if abs(offset) > 0.001:  # Should be very close to 0
		print("  ❌ Timing offset calculation incorrect at optimal timing (expected ~0, got ", offset, ")")
		passed = false
	else:
		print("  ✓ Timing offset calculation works correctly")
	
	# Test perfect quality evaluation
	var quality = timing_system.evaluate_timing(1.425, 0.0)
	if quality != StrikeData.ContactQuality.PERFECT:
		print("  ❌ Perfect timing not detected (offset: ", offset, ")")
		passed = false
	else:
		print("  ✓ Perfect timing detection works")
	
	# Test clean quality evaluation
	quality = timing_system.evaluate_timing(1.2, 0.0)  # 80% power, within clean window
	if quality != StrikeData.ContactQuality.CLEAN:
		print("  ❌ Clean timing not detected")
		passed = false
	else:
		print("  ✓ Clean timing detection works")
	
	# Test okay quality evaluation
	quality = timing_system.evaluate_timing(1.0, 0.0)  # ~67% power, within okay window
	if quality != StrikeData.ContactQuality.OKAY:
		print("  ❌ Okay timing not detected")
		passed = false
	else:
		print("  ✓ Okay timing detection works")
	
	# Test scuffed quality evaluation
	quality = timing_system.evaluate_timing(0.5, 0.0)  # ~33% power, outside okay window
	if quality != StrikeData.ContactQuality.SCUFFED:
		print("  ❌ Scuffed timing not detected")
		passed = false
	else:
		print("  ✓ Scuffed timing detection works")
	
	validation_results["TimingSystem"] = passed
	if not passed:
		all_tests_passed = false


## Print validation summary
func print_summary() -> void:
	print("\n=== VALIDATION SUMMARY ===\n")
	
	for system in validation_results:
		var status = "✓ PASSED" if validation_results[system] else "❌ FAILED"
		print(system, ": ", status)
	
	print("\n")
	if all_tests_passed:
		print("🎉 ALL CORE SYSTEMS VALIDATED SUCCESSFULLY!")
	else:
		print("⚠️  SOME SYSTEMS FAILED VALIDATION - SEE DETAILS ABOVE")
	
	print("\n==============================\n")
