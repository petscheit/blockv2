# The Block (Flutter MVP)

Passive clock app with two runtime states:

- Blank fullscreen background (default)
- Analog clock visible only when phone tilt reaches target window

This MVP intentionally **excludes DND/Focus automation** for now, per request.

## Implemented

- iOS-first portrait app structure
- Setup screen (pre-session) for:
  - target angle
  - tolerance
  - clock hand thickness
  - second hand toggle
  - visual theme (`Night` / `Sand`)
- Fullscreen passive session:
  - immersive UI (no normal chrome during session)
  - screen stays awake via `wakelock_plus`
  - tilt detection with accelerometer low-pass gravity estimate
  - hysteresis state machine (enter/exit hold windows)
  - analog clock painter with calm, physical-style depth
- Settings persistence via `shared_preferences`

## macOS Setup (Homebrew-first)

### 1) Install required tools

Install Homebrew (if not already installed):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install Flutter and CocoaPods with Homebrew:

```bash
brew install --cask flutter
brew install cocoapods
```

Verify install:

```bash
flutter --version
pod --version
```

Install Xcode from the App Store (Apple requires this; it is not installed via Homebrew).

After Xcode is installed:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Run:

```bash
flutter doctor
```

Resolve any remaining warnings shown by `flutter doctor`.

### 2) Enable iPhone Developer Mode (required)

1. Connect iPhone to Mac with a data cable.
2. Unlock iPhone and tap `Trust` if prompted.
3. On iPhone, go to `Settings > Privacy & Security > Developer Mode`.
4. Turn Developer Mode ON and restart the iPhone if prompted.
5. After reboot, unlock iPhone and confirm Developer Mode.

### 3) Register your Apple developer account in Xcode

1. Open Xcode.
2. Go to `Xcode > Settings > Accounts`.
3. Click `+` and sign in with your Apple ID.
4. Select your Apple ID and open `Manage Certificates...`.
5. Ensure an `Apple Development` certificate exists.
   - If missing, click `+` and create one.
6. Open [Apple Developer Account](https://developer.apple.com/account) once in browser and accept any pending agreements.

### 4) Open and configure this project for iPhone

From this folder:

```bash
cd /Users/paul/Documents/projects/blockv2
flutter create .
flutter pub get
open ios/Runner.xcworkspace
```

In Xcode:

1. Select the `Runner` target.
2. Open `Signing & Capabilities`.
3. Turn ON `Automatically manage signing`.
4. Set `Team` to your personal team.
5. Set a unique `Bundle Identifier` (example: `com.pauli.blockv2`).
6. In the top toolbar, set run destination to your **connected iPhone** (not simulator, not "Any iOS Device").

### 5) Build and run on the connected iPhone

First run from Xcode once:

1. Press `Product > Clean Build Folder`.
2. Press Run (`▶`).

Then you can run from terminal:

```bash
cd /Users/paul/Documents/projects/blockv2
flutter devices
flutter run -d <your_iphone_device_id>
```

## Notes

- Tilt angle is measured as degrees away from flat/horizontal.
- Enter clock: within tolerance for ~200ms.
- Exit clock: outside tolerance + hysteresis margin for ~200ms.
- Session UI remains interaction-free; leave session with standard OS/app navigation.
