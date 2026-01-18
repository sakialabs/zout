# Zout ⚽

Zout is what the beautiful game is about.

It doesn’t matter where you are.  
Street, park, cage, or stadium.

The pause. The run-up. The strike.  
The net is waiting.

Zout. Let the celebration begin.

---

## 🚀 Getting Started

**First time here?**

1. Double-click `start.bat` to open the editor
2. Read [`docs/setup.md`](docs/setup.md) for complete setup instructions
3. Check [`docs/vision.md`](docs/vision.md) and [`docs/tone.md`](docs/tone.md) for design philosophy

**Development Status:**

- ✅ Phase 1: Core Strike Mechanic (Tasks 1-11)
- ✅ Phase 2: Zout Logic - Audio/Camera/Scoring (Tasks 12-19)
- ✅ Phase 3: Practice Mode Loop (Tasks 20-28)

**Quick Links:**

- 📋 [Changelog](docs/CHANGELOG.md) - Release history and updates
- 🗺️ [Roadmap](docs/roadmap.md) - Future plans and milestones
- 🧪 [Testing Guide](docs/testing.md) - Run and write tests
- 🏗️ [Requirements](docs/requirements.md) - Feature specifications
- 📐 [System Design](docs/design.md) - Architecture details

---

## 📁 Project Structure

```plaintext
zout/
├── audio/              # Audio files (strike sounds, voice lines)
├── docs/               # Documentation (vision, roadmap, testing, changelog)
├── scenes/             # Godot scene files (.tscn)
├── scripts/            # GDScript source code
├── tests/              # Automated tests organized by type
│   ├── unit/           # Unit tests for individual components
│   ├── property/       # Property-based tests (PBT)
│   ├── integration/    # Integration tests for system coordination
│   └── scenes/         # Test scene files
└── tools/              # Development utilities and test runners
```

**Quick Navigation:**

- 🎮 **Play:** Open `scenes/practice_mode.tscn` in Godot
- 💻 **Code:** See [`scripts/README.md`](scripts/README.md) for all scripts
- 🧪 **Test:** Run `tools\run_all_tests.bat` or see [`tests/README.md`](tests/README.md)
- 📚 **Learn:** Check [`docs/README.md`](docs/README.md) for documentation

Each folder has its own README explaining its contents.

---

## 🎮 The Game

Zout is a football (soccer) striking game about **feel**, **timing**, and **clean contact** 💫

One mechanic.  
One moment.  
Endless pressure.

You control:

- 🎯 **Aim**
- 💪 **Power**
- ⏱️ **Timing**

Everything else reacts.

---

## 🧠 Modes

### 🏋️ Practice

No crowd.  
No keeper.  
No pressure.

Repetition builds control.  
Timing becomes instinct.

This is training.

---

### 🥶 Penzie

One shot.  
Crowd watching.  
Keeper staring you down.

Psychology over power.  
Calm beats chaos.

This is composure.

---

### 🧱 Free Kick

Wall set.  
Keeper ready.  
All eyes on you.

Curl it 🌀  
Knuckle it 🧨  
Smash it 💥

This is performance.

---

## 💫 Contact Quality

Contact quality affects how the ball behaves.  
It is felt, not announced.

- **Perfect** – maximum stability and efficiency  
- **Clean** – strong and reliable  
- **Okay** – playable, imperfect  
- **Scuffed** – drift and instability  

Contact quality influences accuracy, speed, and consistency.

---

## 🎯 Zout & Top Bins

- **Zout** is called when the ball goes in.  
- **Top bins** is earned when the goal hits the top corner.

They can happen together.

Zout confirms the goal.  
Top bins elevates it.

---

## 🧮 Scoring

Scoring is layered and intentional.

- **Goal (Zout)** → base points  
- **Top Bins** → bonus points  
- **Contact Quality** → multiplier  

Example:

- Goal → **100**
- Goal + Top Bins → **150**
- Goal + Top Bins + Perfect contact → **188**

The cleaner the strike, the more it counts.

---

## 🎉 Celebration

Celebration follows the outcome.

Not every goal earns the same response.  
The cleaner the strike, the stronger the release.

Some shots end quietly.  
Some deserve a moment.

That contrast is intentional.

---

## 🔊 Audio

Sound is part of the feedback.

- Clean strikes sound sharper.
- Perfect execution is unmistakable.
- Top bins is recognizable with eyes closed.

Short cues.  
Classic energy.  
No noise.

---

## 🌍 Scenery

Zout lives anywhere football is played.

Streets 🛣️  
Parks 🌳  
Cages 🥅  
Stadiums 🏟️  

Different places.  
Same strike.

---

## 🎧 Vibe

Minimal camera 🎥  
Sharp audio 🔊  
Focused moments 💫  

No clutter.  
No distractions.

Just the strike ⚽

---

## 🛠️ Tech

- 🎮 **Engine:** Godot 4  
- 🧠 **Language:** GDScript  
- 💻 **Platform:** Desktop first  
- 🎯 **Philosophy:** feel > features  

---

## 🚧 Status

Early development.  
Currently locking the core strike feel in **Practice mode**.

Next up: Zout logic (audio, camera, scoring).

---

## 📄 License

MIT

---

Made with 💖 for the joy of zout.  
The strike you hit once and think about all day.
