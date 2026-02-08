## The Block App — Product + Technical Spec (MVP: “Passive Clock”)

### 1) Purpose

A single-purpose app that turns an iPhone into a passive object: **no interaction, no feeds, no UI chrome**—only a minimalist clock that appears when the phone is placed at a specific tilt (e.g., ~20°). The app is designed to support “undesigned function”: the phone becomes less smart while in use.

**Core promise**

* **No calls, no notifications, just a clock.**
* “A stupid object for a smart world.”

---

### 2) Scope (this spec covers only the app)

**In scope**

* Fullscreen passive display with two states:

  1. **Blank state** (default)
  2. **Clock state** (triggered by device angle)
* Optional “focus/quiet” behavior on iOS via user-configured automation (see Section 8)

**Out of scope**

* NFC tag behavior / hardware block behavior
* Backend services
* Accounts, social features, cloud sync

---

### 3) Platforms

* **iOS first** (iPhone)
* (Optional later) Android parity

---

### 4) Primary User Flow

1. User opens the app.
2. Screen goes full-bleed, minimal, dark background.
3. When the phone reaches the configured angle (e.g., ~20° from horizontal), the **clock appears**.
4. When the phone leaves that angle range, the clock disappears back to blank.

---

### 5) UX / Visual Design

#### 5.1 Visual language

* High-contrast minimalism.
* No buttons, no tabs, no settings visible during “session.”
* Clock style: bold hands, limited palette, large negative space (similar to your reference image conceptually).

#### 5.2 States

**A) Blank state**

* Solid background (default: near-black).
* No status bar, no home indicator emphasis.

**B) Clock state**

* Analog clock (MVP) or analog + optional digital (later).
* Smooth second hand optional (battery tradeoff).
* Anti-burn-in micro-drift (optional later for OLED).

#### 5.3 Interaction model

* No taps required for core behavior.
* Optional: a **long-press with 2-step confirmation** to exit session (later), but MVP can rely on normal iOS gestures.

---

### 6) Motion / Angle Trigger

#### 6.1 Trigger definition

* Use device motion to infer tilt relative to gravity.
* **Target tilt angle:** 20° (configurable later)
* **Activation window:** 20° ± 5° (example)
* **Hysteresis:** to prevent flicker

  * Enter clock: within ±5° for 200ms
  * Exit clock: outside ±8° for 200ms

#### 6.2 Sensor approach (iOS)

* Use Core Motion (deviceMotion / gravity vector).
* Compute pitch/roll angle and compare against threshold.

#### 6.3 Performance/battery rules

* While app is foreground:

  * Motion sampling: 30–60 Hz (tune)
  * Clock render: 1 Hz (tick) or 60 Hz (smooth) depending on chosen style
* When clock is hidden: can reduce refresh rate and/or sampling.

---

### 7) System Behavior (Foreground Session)

* **Keep screen awake** while in session using `UIApplication.isIdleTimerDisabled` so the device doesn’t auto-lock during passive use. ([Apple Developer][1])
* Force immersive UI:

  * Hide status bar where allowed
  * Use a single fullscreen view
* Orientation: fixed (portrait) unless you intentionally support landscape.

---

### 8) iOS “Do Not Disturb / Focus” Research + Integration Plan

#### 8.1 What iOS allows (important constraint)

* **Apps cannot programmatically toggle Do Not Disturb / Focus modes directly.** Apple does not provide a public API to switch DND on/off from an app. ([Apple Support Community][2])

#### 8.2 What iOS does allow instead

**A) Shortcuts Automations (recommended)**

* Users can create a Personal Automation in Apple’s **Shortcuts** app to enable a Focus mode when:

  * the app opens, or
  * an NFC tag is scanned (later, if/when you reintroduce NFC in the overall project)
* Apple documents that automations can be triggered by Focus changes; Shortcuts supports multiple trigger types and “Run Immediately” behavior. ([Apple Support][3])
* Practical NFC→Focus automation guidance is widely used (community references). ([DEV Community][4])

**How this maps to your MVP (no NFC required):**

* In onboarding, instruct users to create an automation:
  **When “The Block” is opened → Set Focus (Do Not Disturb) ON**
  **When “The Block” is closed → Set Focus OFF** (or restore previous Focus)
* Your app can deep-link users to Shortcuts and provide step-by-step UI screens, but the user must confirm and own the automation.

**B) Focus awareness inside your app (optional)**

* iOS provides APIs for apps to **respond to** Focus changes and define Focus filters (to adapt app behavior/notification handling), but this is not the same as toggling Focus. ([Apple Developer][5])

#### 8.3 MVP decision

* **MVP includes onboarding instructions for Shortcuts-based Focus toggling.**
* App itself:

  * does not claim it can enforce DND
  * optionally detects and displays a small, non-intrusive indicator like “Focus: ON” (if you choose to read system state; keep UI minimal)

---

### 9) Settings (Minimal, outside the “session”)

A separate configuration screen accessible only before entering the passive session (or via a hidden gesture).

**MVP settings**

* Tilt angle target (default 20°)
* Angle tolerance (default ±5°)
* Clock style:

  * Analog hand thickness
  * Optional second hand
* Background theme (dark/light, but default dark)

**Optional settings (later)**

* Night mode auto
* Burn-in protection
* “Smooth seconds” toggle (battery vs aesthetics)

---

### 10) Non-Functional Requirements

* Launch to usable blank screen in < 1 second on modern devices.
* No network required.
* No tracking/analytics in MVP (or strictly opt-in).
* Accessibility:

  * Large clock option
  * High-contrast
  * VoiceOver label for the clock (even if UI is minimal)

---

### 11) Technical Architecture (iOS)

* **UI:** SwiftUI (preferred for fast iteration) or UIKit
* **Motion:** CoreMotion manager service
* **Rendering:** vector-based clock (SwiftUI shapes / Canvas)
* **Power management:** `isIdleTimerDisabled = true` during session ([Apple Developer][1])

**Core modules**

1. `MotionService`

   * Provides tilt angle stream (Combine / async sequence)
2. `SessionController`

   * State machine: Blank ↔ Clock (with hysteresis)
3. `ClockView`

   * Stateless rendering from current time
4. `Onboarding`

   * Shortcuts automation instructions for Focus mode

---

### 12) Acceptance Criteria (MVP)

* App opens to fullscreen blank screen.
* When device reaches ~20° (within tolerance) and remains stable briefly, clock appears.
* When device leaves angle window, clock disappears without flicker.
* Screen does not auto-lock while session is active.
* Onboarding clearly explains iOS limitation and guides user to enable Focus via Shortcuts.

---

### 13) Risks / Constraints

* **Hard constraint:** Cannot toggle iOS DND/Focus directly from the app. ([Apple Support Community][2])
* Always-on screen increases battery drain; mitigate via dark UI, 1Hz ticking, and reduced motion sampling when stable.

---

## Appendix — Shortcuts Onboarding Copy (Draft)

* “iOS doesn’t allow apps to enable Do Not Disturb automatically. To silence notifications while using The Block, set up an iPhone Shortcut Automation.”
* Steps:

  1. Open **Shortcuts** → **Automation** → **+**
  2. Choose **App** → select **The Block** → “Is Opened”
  3. Add action: **Set Focus** → **Do Not Disturb** → **On**
  4. Set **Run Immediately**
  5. (Optional) Create a second automation for “Is Closed” → Set Focus Off

(You can keep this as a minimal 2–3 screen onboarding with illustrations.)

---

If you want, I can turn this into a more formal “spec file” format (PRD + TRD) with numbered requirements (R1, R2, …) and an explicit state machine diagram description.

[1]: https://developer.apple.com/documentation/uikit/uiapplication/isidletimerdisabled?utm_source=chatgpt.com "isIdleTimerDisabled | Apple Developer Documentation"
[2]: https://discussions.apple.com/thread/4871887?utm_source=chatgpt.com "programmatically turn on “do not disturb”"
[3]: https://support.apple.com/en-am/guide/shortcuts/apde31e9638b/ios?utm_source=chatgpt.com "Setting triggers in Shortcuts on iPhone or iPad"
[4]: https://dev.to/djchadderton/customising-focus-till-morning-in-shortcuts-app-1mhj?utm_source=chatgpt.com "Customising 'focus till morning' in Shortcuts app"
[5]: https://developer.apple.com/documentation/appintents/focus?utm_source=chatgpt.com "Focus | Apple Developer Documentation"
