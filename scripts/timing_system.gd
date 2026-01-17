class_name TimingSystem
extends RefCounted

## Evaluates contact timing and determines quality
## Validates: Requirements 1.3, 1.4

# Timing windows (in seconds from optimal timing)
const PERFECT_WINDOW: float = 0.05  # ±0.05s from optimal
const CLEAN_WINDOW: float = 0.15    # ±0.15s from optimal
const OKAY_WINDOW: float = 0.30     # ±0.30s from optimal

# Optimal timing configuration
# Optimal timing occurs at 90-100% power range
const OPTIMAL_POWER_MIN: float = 0.90  # 90% power
const OPTIMAL_POWER_MAX: float = 1.00  # 100% power

# Power system reference for timing calculations
var power_system  # PowerSystem reference
var charge_duration: float = 1.5  # Default charge duration (seconds)


func _init(power_sys = null) -> void:
	if power_sys:
		power_system = power_sys
		charge_duration = power_sys.charge_duration


## Evaluate timing to determine ContactQuality from release time
## release_time: The time when power was released (in seconds)
## charge_start_time: The time when charging began (in seconds)
## Returns: ContactQuality based on timing precision
func evaluate_timing(release_time: float, charge_start_time: float) -> StrikeData.ContactQuality:
	var timing_offset = get_timing_offset(release_time, charge_start_time)
	var abs_offset = abs(timing_offset)
	
	# Calculate power level at release time
	var elapsed_time = release_time - charge_start_time
	var power = clamp(elapsed_time / charge_duration, 0.0, 1.0)
	
	# Determine quality based on timing windows
	if abs_offset <= PERFECT_WINDOW:
		# Perfect timing window - only if in optimal power range
		if power >= OPTIMAL_POWER_MIN:
			return StrikeData.ContactQuality.PERFECT
		else:
			return StrikeData.ContactQuality.CLEAN
	elif abs_offset <= CLEAN_WINDOW:
		# Clean timing window
		return StrikeData.ContactQuality.CLEAN
	elif abs_offset <= OKAY_WINDOW:
		# Okay timing window
		return StrikeData.ContactQuality.OKAY
	else:
		# Outside all timing windows
		return StrikeData.ContactQuality.SCUFFED


## Calculate offset from optimal timing
## release_time: The time when power was released (in seconds)
## charge_start_time: The time when charging began (in seconds)
## Returns: Timing offset in seconds (negative = early, positive = late)
func get_timing_offset(release_time: float, charge_start_time: float) -> float:
	var elapsed_time = release_time - charge_start_time
	
	# Calculate optimal timing point (midpoint of optimal power range)
	# Optimal power range is 90-100%, so optimal timing is at 95% power
	var optimal_power = (OPTIMAL_POWER_MIN + OPTIMAL_POWER_MAX) / 2.0  # 0.95
	var optimal_time = optimal_power * charge_duration
	
	# Calculate offset from optimal timing
	var offset = elapsed_time - optimal_time
	
	return offset

</content>
