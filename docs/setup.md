# Zout Practice Mode - Complete Setup & Development Guide

## 🚀 Quick Start

### Prerequisites

- **Godot 4.3+** - [Download here](https://godotengine.org/download)
- **Git** (optional) - For cloning the repository

### Launch Commands

- **Open Editor**: Double-click `start.bat` (or `tools/launch_godot_editor.bat`)
- **Run Game**: Press **F5** in Godot Editor
- **Run Tests**: `tools/run_all_tests.bat`

---

## ⌨️ Essential Shortcuts

### Editor

- **F5** - Run project
- **F6** - Run current scene
- **F8** - Stop game
- **Ctrl+S** - Save
- **Ctrl+Z/Y** - Undo/Redo

### Game Controls

- **WASD/Arrows** - Aim direction
- **Space** - Hold to charge, release to strike
- **R** - Reset
- **C** - Toggle aim assist
- **T** - Toggle trajectory preview
- **Tab** - Toggle stats
- **ESC** - Main menu

---

## 📁 Project Structure

```plaintext
zout/
├── scenes/              # Game scenes
│   ├── practice_mode.tscn
│   └── core_systems_validation.tscn
├── scripts/             # GDScript files
│   ├── strike_data.gd
│   ├── outcome_data.gd
│   ├── session_stats.gd
│   ├── contact_quality_calculator.gd
│   ├── aim_system.gd
│   ├── power_system.gd
│   └── timing_system.gd
└── docs/                # Documentation
```

---

## 🎯 Strike Mechanic Flow

```plaintext
AIMING → CHARGING → CONTACT → FLIGHT → OUTCOME → RESET
  ↓         ↓          ↓         ↓         ↓
WASD     Space      Release   Physics   Goal?
```

---

## 🏆 Contact Quality System

| Quality | Timing | Power | Multiplier | Drift |
|---------|--------|-------|------------|-------|
| PERFECT | ±0.05s | 90-100% | 1.25x | 0° |
| CLEAN | ±0.15s | Any | 1.0x | ≤2° |
| OKAY | ±0.30s | Any | 0.85x | ≤5° |
| SCUFFED | >±0.30s | <20% | 0.7x | ≤10° |

---

## 📊 Development Progress

### ✅ Completed - MVP READY

**All 28 mandatory tasks complete!**
- Core strike mechanics (aim, power, timing, quality)
- Ball physics and goal detection
- Feedback systems (audio, camera, UI)
- Scoring and statistics
- Assist system
- Main menu and settings
- Polish pass
- Build ready

See [CHANGELOG.md](CHANGELOG.md) for full release notes.

---

## 🛠️ Godot Editor Basics

### Main Areas

- **Scene Tree** (left) - All nodes in scene
- **Inspector** (right) - Node properties
- **Viewport** (center) - 3D/2D view
- **FileSystem** (bottom left) - Project files
- **Output** (bottom) - Console/errors

### Key Node Types

- **Node3D** - Base 3D object
- **RigidBody3D** - Physics object (ball)
- **Area3D** - Trigger zone (goal)
- **Camera3D** - Player view
- **MeshInstance3D** - Visible 3D model

---

## 💡 GDScript Quick Reference

```gdscript
# Variables
var speed: float = 10.0
var is_goal: bool = true

# Functions
func calculate_score(quality: ContactQuality) -> int:
    return 100

# Signals
signal strike_executed
emit_signal("strike_executed")

# Get nodes
var ball = $Ball
var ball = get_node("Ball")

# Debug
print("Debug message")
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Godot won't open | Check `C:\Godot\` exists, run as admin |
| Scene won't load | Verify `project.godot` exists |
| Script errors | Check Output panel |
| Slow performance | Update GPU drivers |

---

## 🏗️ Building the Game

### Prerequisites
1. Install Godot export templates: **Editor → Manage Export Templates → Download**
2. Configure export presets: **Project → Export** (add Windows/Linux/macOS)

### Build Commands

**Automated (Recommended):**
```bash
tools\build_all.bat
```

**Manual Export:**
```bash
# Windows
godot --headless --export-release "Windows Desktop" "builds/Zout_Windows.exe"

# Linux
godot --headless --export-release "Linux/X11" "builds/Zout_Linux.x86_64"

# macOS
godot --headless --export-release "macOS" "builds/Zout_macOS.zip"
```

### Testing the Build
- Verify 60 FPS performance
- Test all features end-to-end
- Check settings persistence
- Validate on target platforms

---

## 📚 Learning Resources

- [Official Godot Docs](https://docs.godotengine.org/en/stable/)
- [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [First 3D Game Tutorial](https://docs.godotengine.org/en/stable/getting_started/first_3d_game/index.html)

---

## 🎮 Zout Philosophy

**"Feel over Features"**

- Every strike feels intentional
- Quality > quantity
- Calm, focused practice
- No UI spam
- Earned recognition (Zout!)

---

## 🚀 Quick Reference

**Controls:**
- WASD/Arrows: Aim
- Space: Charge/Strike
- R: Reset
- C: Toggle aim assist
- T: Toggle trajectory
- Tab: Toggle stats
- ESC: Main menu

**Settings:**
- Saved to `user://settings.cfg`
- Persist between sessions
- Toggle sound/assists

---

**You've got this! Let's build something awesome! ⚽✨**
