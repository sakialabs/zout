# Requirements Document

## Introduction

Zout Practice Mode is the foundational experience that proves the core striking mechanic. It provides an infinite, pressure-free environment where players develop muscle memory for aim, power, and timing. Practice Mode must feel intentional - every strike should communicate quality through physics and feedback, not UI spam. This mode establishes the "feel" that defines Zout.

## Glossary

- **Strike_System**: The core mechanic combining aim, power charge, and contact timing
- **Contact_Quality**: Internal measure of execution precision (Perfect, Clean, Okay, Scuffed)
- **Zout**: Audio/visual confirmation triggered when the ball crosses the goal line
- **Top_Bins**: Bonus recognition for goals placed in the top corner zones
- **Practice_Mode**: Infinite attempt mode with optional assists and stat tracking
- **Ball_Physics**: Physics simulation determining ball trajectory based on strike parameters
- **Assist_System**: Optional visual guides for aim and shot preview

## Requirements

### Requirement 1: Core Strike Mechanic

**User Story:** As a player, I want to control aim, power, and timing for each strike, so that I can execute intentional shots that feel different based on my input quality.

#### Acceptance Criteria

1. WHEN a player initiates a strike, THE Strike_System SHALL accept aim input via keyboard or mouse
2. WHEN a player holds the power input, THE Strike_System SHALL charge power from 0% to 100% over a defined duration
3. WHEN a player releases the power input, THE Strike_System SHALL capture the timing offset from the optimal contact window
4. WHEN strike parameters are captured, THE Strike_System SHALL calculate Contact_Quality based on timing precision
5. THE Strike_System SHALL apply strike parameters to Ball_Physics to determine trajectory, speed, and stability

### Requirement 2: Contact Quality System

**User Story:** As a player, I want my execution quality to affect ball behavior, so that I can feel the difference between clean and scuffed strikes without UI distractions.

#### Acceptance Criteria

1. WHEN Contact_Quality is Perfect, THE Ball_Physics SHALL apply maximum accuracy and stability with no drift
2. WHEN Contact_Quality is Clean, THE Ball_Physics SHALL apply strong accuracy with minimal drift
3. WHEN Contact_Quality is Okay, THE Ball_Physics SHALL apply moderate accuracy with noticeable drift
4. WHEN Contact_Quality is Scuffed, THE Ball_Physics SHALL apply reduced accuracy with significant instability
5. THE Strike_System SHALL NOT display Contact_Quality values during gameplay

### Requirement 3: Goal Detection and Zout

**User Story:** As a player, I want clear confirmation when I score, so that successful strikes feel earned and recognized.

#### Acceptance Criteria

1. WHEN the ball fully crosses the goal line, THE Strike_System SHALL trigger the Zout confirmation
2. WHEN the ball misses the goal, THE Strike_System SHALL NOT trigger Zout
3. WHEN Zout is triggered, THE Strike_System SHALL play the Zout audio cue
4. WHEN Zout is triggered, THE Strike_System SHALL display minimal visual feedback
5. THE Strike_System SHALL NOT trigger Zout for near-misses or saved shots

### Requirement 4: Top Bins Detection

**User Story:** As a player, I want recognition for placing shots in the top corners, so that placement mastery feels rewarded.

#### Acceptance Criteria

1. WHEN the ball crosses the goal line within the top corner zones, THE Strike_System SHALL trigger Top_Bins recognition
2. WHEN Top_Bins is triggered, THE Strike_System SHALL stack Top_Bins feedback on top of Zout
3. WHEN Top_Bins is triggered, THE Strike_System SHALL play a distinct Top_Bins audio cue
4. WHEN Top_Bins is triggered, THE Strike_System SHALL apply subtle camera emphasis toward the corner
5. THE Strike_System SHALL define top corner zones as the upper 25% of goal height and outer 30% of goal width

### Requirement 5: Scoring System

**User Story:** As a player, I want my score to reflect both outcome and execution quality, so that clean strikes matter more than lucky ones.

#### Acceptance Criteria

1. WHEN Zout is triggered, THE Strike_System SHALL award 100 base points
2. WHEN Top_Bins is triggered, THE Strike_System SHALL add 50 bonus points
3. WHEN scoring is calculated, THE Strike_System SHALL apply Contact_Quality as a multiplier (Perfect: 1.25x, Clean: 1.0x, Okay: 0.85x, Scuffed: 0.7x)
4. WHEN points are awarded, THE Strike_System SHALL display the total briefly without showing calculation details
5. THE Strike_System SHALL accumulate total score across all attempts in the session

### Requirement 6: Practice Mode Loop

**User Story:** As a player, I want to take unlimited shots with fast reset, so that I can focus on repetition and improvement without friction.

#### Acceptance Criteria

1. WHEN Practice_Mode starts, THE Strike_System SHALL position the ball at the strike point
2. WHEN a strike is completed, THE Strike_System SHALL reset the ball to the strike point within 2 seconds
3. WHEN the player requests manual reset, THE Strike_System SHALL immediately reset the ball and clear any active feedback
4. THE Practice_Mode SHALL allow infinite attempts without ending conditions
5. THE Practice_Mode SHALL maintain session continuity until the player exits

### Requirement 7: Assist System

**User Story:** As a player, I want optional visual guides, so that I can learn the mechanics before relying on feel alone.

#### Acceptance Criteria

1. WHERE aim assist is enabled, THE Assist_System SHALL display a directional cone showing aim direction
2. WHERE shot preview is enabled, THE Assist_System SHALL display a trajectory arc based on current power and aim
3. WHEN assists are disabled, THE Assist_System SHALL hide all visual guides
4. THE Assist_System SHALL allow toggling assists during gameplay without resetting progress
5. THE Assist_System SHALL NOT affect ball physics or scoring calculations

### Requirement 8: Session Statistics

**User Story:** As a player, I want to see basic stats for my session, so that I can track improvement and set personal goals.

#### Acceptance Criteria

1. WHEN Practice_Mode is active, THE Strike_System SHALL track total goals scored
2. WHEN Practice_Mode is active, THE Strike_System SHALL track total Top_Bins goals
3. WHEN Practice_Mode is active, THE Strike_System SHALL track current goal streak
4. WHEN Practice_Mode is active, THE Strike_System SHALL track best goal streak for the session
5. WHEN the player requests stats, THE Strike_System SHALL display statistics in a non-intrusive overlay

### Requirement 9: Camera Behavior

**User Story:** As a player, I want the camera to enhance the strike moment without distracting from it, so that visual feedback feels natural and earned.

#### Acceptance Criteria

1. WHEN the player is aiming, THE Strike_System SHALL position the camera behind the ball with calm framing
2. WHEN power is charging, THE Strike_System SHALL apply subtle camera push-in
3. WHEN the ball is struck, THE Strike_System SHALL apply micro camera shake on impact
4. WHEN Zout is triggered, THE Strike_System SHALL hold the camera briefly with minimal slow-motion
5. WHEN Top_Bins is triggered, THE Strike_System SHALL add slight emphasis toward the corner without rotation

### Requirement 10: Audio Feedback

**User Story:** As a player, I want audio to communicate strike quality and outcomes, so that I can recognize success with my eyes closed.

#### Acceptance Criteria

1. WHEN the ball is struck, THE Strike_System SHALL play impact audio layered by Contact_Quality
2. WHEN the ball hits the net, THE Strike_System SHALL play net audio distinct from the crossbar or post
3. WHEN Zout is triggered, THE Strike_System SHALL play the Zout voice line
4. WHEN Top_Bins is triggered, THE Strike_System SHALL play the Top_Bins audio cue
5. THE Strike_System SHALL NOT repeat identical voice lines consecutively

### Requirement 11: Scene Setup

**User Story:** As a developer, I want a complete practice scene with all necessary elements, so that the core mechanic can be tested immediately.

#### Acceptance Criteria

1. THE Practice_Mode SHALL include a pitch surface with appropriate visual treatment
2. THE Practice_Mode SHALL include a goal with net physics
3. THE Practice_Mode SHALL include a ball with realistic physics properties
4. THE Practice_Mode SHALL include appropriate lighting for the practice environment
5. THE Practice_Mode SHALL load within 3 seconds on target hardware

### Requirement 12: Input Handling

**User Story:** As a player, I want responsive controls that feel immediate, so that my inputs translate directly to on-screen actions.

#### Acceptance Criteria

1. WHEN the player provides aim input, THE Strike_System SHALL update aim direction within one frame
2. WHEN the player presses the power button, THE Strike_System SHALL begin power charge immediately
3. WHEN the player releases the power button, THE Strike_System SHALL execute the strike within one frame
4. WHEN the player presses the reset button, THE Strike_System SHALL reset the scene within 0.5 seconds
5. THE Strike_System SHALL support both keyboard and mouse input schemes
