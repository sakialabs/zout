class_name PowerSystem
extends RefCounted

## Manages power charge timing and level calculation
## Validates: Requirements 1.2, 12.2

# Configuration
var charge_duration: float = 1.5  # Time to reach 100% power (seconds)

# Power thresholds
const MIN_POWER_THRESHOLD: float = 0.20  # 20% minimum viable power

# State tracking
var is_charging: bool = false
var charge_start_time: float = 0.0


## Begin power accumulation
func start_charge() -> void:
	is_charging = true
	charge_start_time = Time.get_ticks_msec() / 1000.0


## Calculate current power based on elapsed time
## Returns power level from 0.0 to 1.0 (0% to 100%)
func get_current_power() -> float:
	if not is_charging:
		return 0.0
	
	var current_time = Time.get_ticks_msec() / 1000.0
	var elapsed_time = current_time - charge_start_time
	
	# Linear accumulation from 0% to 100%
	var power = elapsed_time / charge_duration
	
	# Clamp to 100% (no penalty for holding)
	return clamp(power, 0.0, 1.0)


## Finalize and return power level
## Returns the final power level, or -1.0 if below minimum threshold
func release_charge() -> float:
	if not is_charging:
		return 0.0
	
	var final_power = get_current_power()
	is_charging = false
	
	# Reject strikes below minimum power threshold
	if final_power < MIN_POWER_THRESHOLD:
		return -1.0  # Indicates rejected strike
	
	return final_power
