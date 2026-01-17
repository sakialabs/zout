class_name StrikeData
extends RefCounted

## Encapsulates all parameters of a single strike
## Validates: Requirements 1.1, 1.2, 1.3, 1.4

enum ContactQuality {
	PERFECT,  # 1.25x multiplier
	CLEAN,    # 1.0x multiplier
	OKAY,     # 0.85x multiplier
	SCUFFED   # 0.7x multiplier
}

var aim_direction: Vector3
var power_level: float
var timing_offset: float
var contact_quality: ContactQuality
var timestamp: float


func _init(direction: Vector3, power: float, timing: float, quality: ContactQuality) -> void:
	aim_direction = direction
	power_level = power
	timing_offset = timing
	contact_quality = quality
	timestamp = Time.get_ticks_msec() / 1000.0
