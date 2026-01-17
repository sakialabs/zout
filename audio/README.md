# Audio

This directory contains all audio files for Zout.

## Audio Files

### Strike Sounds (Contact Quality)
- **`strike_perfect.wav`** - Perfect contact sound (clean, crisp)
- **`strike_clean.wav`** - Clean contact sound (solid)
- **`strike_okay.wav`** - Okay contact sound (decent)
- **`strike_scuffed.wav`** - Scuffed contact sound (weak, muffled)

**Usage:** Layered based on contact quality to communicate execution precision.

### Impact Sounds
- **`net_impact.wav`** - Ball hitting the net (distinct from post/crossbar)
- **`post_impact.wav`** - Ball hitting the post or crossbar
- **`ground_impact.wav`** - Ball hitting the ground

### Voice Lines
- **`zout_call.wav`** - "Zout!" confirmation when ball crosses goal line
- **`top_bins_call.wav`** - "Top Bins!" recognition for top corner goals

**Usage:** Triggered on goal detection. Consecutive identical voice lines are prevented.

## Audio Format

All audio files should be:
- **Format:** WAV (uncompressed)
- **Sample Rate:** 44.1 kHz
- **Bit Depth:** 16-bit
- **Channels:** Mono (for 3D spatial audio) or Stereo (for UI sounds)

## Audio Integration

Audio is managed by `scripts/audio_feedback.gd`:
- Strike sounds play immediately on contact
- Net impact plays on first net collision
- Zout call plays 0.1s after goal detection
- Top Bins call plays for top corner goals

## Placeholder Audio

If audio files are missing, the system uses silent fallback to prevent crashes. See `tools/create_placeholder_audio.gd` for generating placeholder files.

## Audio Guidelines (Zout Tone)

Audio should match Zout's restrained, confident tone:
- **Strike sounds:** Realistic, not exaggerated
- **Voice lines:** Clear, calm, earned (not hyped)
- **Impact sounds:** Subtle, natural
- **No music:** Practice mode is focused and quiet

## Volume Levels

Recommended relative volumes:
- Strike sounds: 0.8 (main audio)
- Net impact: 0.6 (supporting)
- Voice lines: 1.0 (clear confirmation)
- Post/ground impact: 0.5 (background)

## Adding New Audio

1. Export audio in WAV format (44.1kHz, 16-bit)
2. Place file in this directory
3. Update `audio_feedback.gd` to reference the new file
4. Test in-game to ensure volume/timing feels right

## Audio Testing

Test audio by:
1. Running `scenes/practice_mode.tscn`
2. Executing strikes with different contact qualities
3. Scoring goals (regular and Top Bins)
4. Listening for appropriate audio feedback

See `docs/testing.md` for detailed audio testing procedures.

## Notes

- Audio files are loaded at runtime using `AudioStreamPlayer` nodes
- Missing files log warnings but don't crash the game
- Voice line tracking prevents consecutive repeats
- All audio respects Godot's audio bus system for volume control
