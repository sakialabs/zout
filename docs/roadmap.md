# Zout ⚽ — MVP Roadmap

## 🎯 MVP Goal

Ship a playable, polished football striking game that *feels right*.

If it doesn’t improve **feel**, **pressure**, or **clarity**, it’s not MVP.

---

## ✅ MVP Definition (Locked)

The MVP is **not**:

- all modes
- all stadiums
- full polish
- feature completeness

The MVP **is**:

- one core mechanic that feels great
- one complete mode that proves the concept
- clear Zout + Top Bins logic
- scoring that makes mastery visible

**MVP Mode:** Practice

---

## Phase 0 — Foundation (Setup & Sanity)

**Goal:** Get to “ball goes in net” fast.

**Deliverables:**

- Godot 4 project setup
- Basic scene:
  - pitch
  - goal
  - ball with physics
- Camera that follows the strike
- Quick reset / retry flow

**Exit Criteria:**

- Shoot → score → reset in under 10 seconds
- Nothing feels broken or confusing

---

## Phase 1 — Core Strike Mechanic (The Heart)

**Goal:** Make the strike feel intentional.

**Deliverables:**

- Aim system (simple cone, keyboard or mouse)
- Power charge (hold → release)
- Contact timing window
- Ball response changes based on contact quality:
  - accuracy
  - speed
  - stability

**Exit Criteria:**

- You feel the difference between scuffed and clean
- You replay shots to “hit it better,” not randomly

---

## Phase 2 — Zout Logic (Outcome Layer)

**Goal:** Separate execution from outcome.

**Deliverables:**

- Goal detection
- Zout call triggered **only when the ball goes in**
- Contact quality remains silent (no UI spam)
- Clear but restrained goal feedback (sound + minimal UI)

**Exit Criteria:**

- Zout is never triggered on a miss
- Goals feel confirmed, not exaggerated

---

## Phase 3 — Top Bins System (Skill Reward)

**Goal:** Reward placement mastery.

**Deliverables:**

- Top bins zones (top corners)
- Top bins detection stacked on Zout
- Distinct Top Bins feedback:
  - unique sound
  - micro pause or camera beat
- Works simultaneously with Zout

**Exit Criteria:**

- Top bins feels rare but achievable
- You can tell it happened even without looking

---

## Phase 4 — Scoring (Make It Count)

**Goal:** Give meaning without clutter.

**Deliverables:**

- Base points for Zout
- Bonus points for Top Bins
- Contact quality multiplier applied silently
- Small point pop or post-shot summary

**Example (Internal Logic):**

- Zout → +100
- Top Bins → +50
- Perfect contact → ×1.25

**Exit Criteria:**

- Players understand *why* a shot mattered
- No visible math during play

---

## Phase 5 — Practice Mode Wrapper (MVP Mode)

**Goal:** Turn mechanics into a game.

**Deliverables:**

- Practice mode loop:
  - infinite attempts
  - fast reset
- Optional assists:
  - aim guide
  - shot preview
- Basic stats:
  - total goals
  - top bins count
  - best streak

**Exit Criteria:**

- Practice mode is fun on its own
- You lose time playing it

---

## Phase 6 — Feel & Juice Pass (Do Not Skip)

**Goal:** Lock the Zout identity.

**Deliverables:**

- Strike sound layering
- Net sound differentiation
- Subtle slow-mo on elite moments
- Camera micro-shake on impact
- No long pauses or forced celebration

**Exit Criteria:**

- Perfect strikes feel *different*, not louder
- Top bins triggers a quiet “ohhh” moment

---

## Phase 7 — MVP Polish & Ship

**Goal:** Make it presentable.

**Deliverables:**

- Simple main menu (Practice only)
- Restart / retry flow
- Basic settings:
  - sound on/off
  - assist toggles
- Desktop build
- One short gameplay clip

**Exit Criteria:**

- You’d proudly share this with a friend
- Nothing feels embarrassing or unfinished

---

## 🚫 Explicitly Out of MVP Scope

(Not now. Not “just one more thing.”)

- Full matches
- Dribbling or passing
- Online multiplayer
- Career mode
- Cosmetics or shops
- Multiple player models

These come **after** the game proves itself.

---

## 🧪 MVP Success Test

The MVP is successful if:

- You replay shots to improve, not to grind
- You chase Top Bins intentionally
- Zout feels earned, not spammed
- The game explains itself through feel, not text

---

## ➡️ Next Steps

When ready:

- Convert this into a task board
- Plan a one-week execution sprint
- Start Penzie mode immediately after MVP lock

Until then:

**Build the strike. Everything else follows.**

