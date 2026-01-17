class_name AudioFeedback
extends Node

## Manages all audio cues with layering and variation
## Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5

# Preload required classes
const StrikeData = preload("res://scripts/strike_data.gd")

# AudioStreamPlayer nodes for different audio types
var strike_perfect_player: AudioStreamPlayer
var strike_clean_player: AudioStreamPlayer
var strike_okay_player: AudioStreamPlayer
var strike_scuffed_player: AudioStreamPlayer
var net_impact_player: AudioStreamPlayer
var zout_call_player: AudioStreamPlayer
var top_bins_call_player: AudioStreamPlayer

# Track last played voice line to prevent consecutive repeats
var last_voice_line: String = ""

# Volume tuning for different audio types (Task 24 - Polish)
var strike_volume: float = -5.0  # Subtle but audible strike sounds
var net_volume: float = -3.0  # More prominent net impact
var voice_volume: float = 0.0  # Full volume for Zout/Top Bins calls

# Audio file paths (placeholders for now)
const AUDIO_PATHS = {
	"strike_perfect": "res://audio/strike_perfect.wav",
	"strike_clean": "res://audio/strike_clean.wav",
	"strike_okay": "res://audio/strike_okay.wav",
	"strike_scuffed": "res://audio/strike_scuffed.wav",
	"net_impact": "res://audio/net_impact.wav",
	"zout_call": "res://audio/zout_call.wav",
	"top_bins_call": "res://audio/top_bins_call.wav"
}


func _ready() -> void:
	# Initialize AudioStreamPlayer nodes
	_create_audio_players()
	
	# Load audio assets (with fallback for missing files)
	_load_audio_assets()


## Create AudioStreamPlayer nodes for each audio type
func _create_audio_players() -> void:
	strike_perfect_player = AudioStreamPlayer.new()
	strike_perfect_player.name = "StrikePerfectPlayer"
	strike_perfect_player.volume_db = strike_volume
	add_child(strike_perfect_player)
	
	strike_clean_player = AudioStreamPlayer.new()
	strike_clean_player.name = "StrikeCleanPlayer"
	strike_clean_player.volume_db = strike_volume
	add_child(strike_clean_player)
	
	strike_okay_player = AudioStreamPlayer.new()
	strike_okay_player.name = "StrikeOkayPlayer"
	strike_okay_player.volume_db = strike_volume
	add_child(strike_okay_player)
	
	strike_scuffed_player = AudioStreamPlayer.new()
	strike_scuffed_player.name = "StrikeScuffedPlayer"
	strike_scuffed_player.volume_db = strike_volume - 2.0  # Scuffed is slightly quieter
	add_child(strike_scuffed_player)
	
	net_impact_player = AudioStreamPlayer.new()
	net_impact_player.name = "NetImpactPlayer"
	net_impact_player.volume_db = net_volume
	add_child(net_impact_player)
	
	zout_call_player = AudioStreamPlayer.new()
	zout_call_player.name = "ZoutCallPlayer"
	zout_call_player.volume_db = voice_volume
	add_child(zout_call_player)
	
	top_bins_call_player = AudioStreamPlayer.new()
	top_bins_call_player.name = "TopBinsCallPlayer"
	top_bins_call_player.volume_db = voice_volume
	add_child(top_bins_call_player)


## Load audio assets with fallback for missing files
func _load_audio_assets() -> void:
	# Load strike sounds
	_load_audio_file(strike_perfect_player, AUDIO_PATHS["strike_perfect"])
	_load_audio_file(strike_clean_player, AUDIO_PATHS["strike_clean"])
	_load_audio_file(strike_okay_player, AUDIO_PATHS["strike_okay"])
	_load_audio_file(strike_scuffed_player, AUDIO_PATHS["strike_scuffed"])
	
	# Load impact sounds
	_load_audio_file(net_impact_player, AUDIO_PATHS["net_impact"])
	
	# Load voice lines
	_load_audio_file(zout_call_player, AUDIO_PATHS["zout_call"])
	_load_audio_file(top_bins_call_player, AUDIO_PATHS["top_bins_call"])


## Load a single audio file with error handling
func _load_audio_file(player: AudioStreamPlayer, path: String) -> void:
	if ResourceLoader.exists(path):
		var audio_stream = load(path) as AudioStream
		if audio_stream != null:
			player.stream = audio_stream
		else:
			push_warning("Failed to load audio file: " + path)
	else:
		push_warning("Audio file not found: " + path + " (using silent fallback)")


## Play strike audio with quality-based layering
## Validates: Requirements 10.1
func play_strike_audio(quality: StrikeData.ContactQuality) -> void:
	match quality:
		StrikeData.ContactQuality.PERFECT:
			if strike_perfect_player.stream != null:
				strike_perfect_player.play()
			else:
				push_warning("Strike perfect audio missing - using fallback")
		
		StrikeData.ContactQuality.CLEAN:
			if strike_clean_player.stream != null:
				strike_clean_player.play()
			else:
				push_warning("Strike clean audio missing - using fallback")
		
		StrikeData.ContactQuality.OKAY:
			if strike_okay_player.stream != null:
				strike_okay_player.play()
			else:
				push_warning("Strike okay audio missing - using fallback")
		
		StrikeData.ContactQuality.SCUFFED:
			if strike_scuffed_player.stream != null:
				strike_scuffed_player.play()
			else:
				push_warning("Strike scuffed audio missing - using fallback")


## Play net impact audio
## Validates: Requirements 10.2
func play_net_audio() -> void:
	if net_impact_player.stream != null:
		net_impact_player.play()
	else:
		push_warning("Net impact audio missing - using fallback")


## Play Zout audio with consecutive voice line prevention
## Validates: Requirements 10.3, 10.4, 10.5
func play_zout_audio(is_top_bins: bool) -> void:
	# Determine which voice line to play
	var voice_line_to_play: String = ""
	
	if is_top_bins:
		voice_line_to_play = "top_bins"
	else:
		voice_line_to_play = "zout"
	
	# Check if this is the same as the last voice line
	if voice_line_to_play == last_voice_line:
		# Skip playing the same voice line consecutively
		push_warning("Skipping consecutive voice line: " + voice_line_to_play)
		return
	
	# Update last voice line tracking (even if audio file is missing)
	last_voice_line = voice_line_to_play
	
	# Play the appropriate voice line with fallback handling
	if is_top_bins:
		if top_bins_call_player.stream != null:
			top_bins_call_player.play()
		else:
			push_warning("Top Bins audio missing - using fallback")
	else:
		if zout_call_player.stream != null:
			zout_call_player.play()
		else:
			push_warning("Zout audio missing - using fallback")


## Reset last voice line tracking (useful for testing or manual reset)
func reset_voice_line_tracking() -> void:
	last_voice_line = ""
