class_name ContactQualityCalculator
extends RefCounted

## Calculates contact quality based on timing windows and power level
## Validates: Requirements 1.4, 2.1, 2.2, 2.3, 2.4, 5.3

# Timing windows (in seconds from optimal timing)
const PERFECT_WINDOW: float = 0.05  # ±0.05s
const CLEAN_WINDOW: float = 0.15    # ±0.15s
const OKAY_WINDOW: float = 0.30     # ±0.30s

# Power thresholds
const MIN_POWER_THRESHOLD: float = 0.20  # 20% minimum
const OPTIMAL_POWER_MIN: float = 0.90    # 90% optimal range start
const OPTIMAL_POWER_MAX: float = 1.00    # 100% optimal range end


## Calculate contact quality based on power and timing offset
## power: Power level from 0.0 to 1.0
## timing_offset: Absolute timing offset from optimal in seconds
func calculate_quality(power: float, timing_offset: float) -> StrikeData.ContactQuality:
	# Reject strikes below minimum power threshold
	if power < MIN_POWER_THRESHOLD:
		return StrikeData.ContactQuality.SCUFFED
	
	# Determine quality based on timing windows
	var abs_offset = abs(timing_offset)
	
	if abs_offset <= PERFECT_WINDOW:
		# Perfect timing window
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


## Get the scoring multiplier for a given contact quality
func get_quality_multiplier(quality: StrikeData.ContactQuality) -> float:
	match quality:
		StrikeData.ContactQuality.PERFECT:
			return 1.25
		StrikeData.ContactQuality.CLEAN:
			return 1.0
		StrikeData.ContactQuality.OKAY:
			return 0.85
		StrikeData.ContactQuality.SCUFFED:
			return 0.7
		_:
			return 1.0  # Fallback to clean multiplier

