# Target AutoEnter (Typeless / shandianshuo)

[![macOS](https://img.shields.io/badge/platform-macOS-lightgrey)](https://www.apple.com/macos/)
[![Objective-C](https://img.shields.io/badge/language-Objective--C-blue)](https://developer.apple.com/documentation/objectivec)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

[中文](README_CN.md) | **English**

A lightweight macOS menu bar utility that automatically presses `Enter` after **Typeless** or **闪电说 (shandianshuo)** finishes voice-to-text input and pastes text via `Cmd+V`.

---

## Why

Voice input tools like Typeless and shandianshuo usually paste recognized text into the current input box using `Cmd+V`.  
In many chat apps and web chat boxes, you still need to press `Enter` manually to send the message.

This tool listens for that paste action, waits briefly, and simulates an `Enter` keypress—so you can keep your hands off the keyboard.

---

## Features

- ✅ Menu bar app (`↩` icon)
- ✅ Supports **Typeless** and **shandianshuo**
- ✅ PID-filtered trigger (only reacts to target processes)
- ✅ Configurable delay (default: 500ms)
- ✅ Global shortcut toggle (`Ctrl + Shift + Enter`)
- ✅ Script toggle via `SIGUSR1` (`./toggle.sh`)
- ✅ `launchd` auto-start support

---

## How it works

1. Scans the process list every 30 seconds and finds target processes by name (`Typeless` / `shandianshuo`)
2. Listens for global `keyDown` events using `CGEvent Tap`
3. Filters events by source PID (only target process events are considered)
4. When `Cmd+V` is detected from a target process, starts a delay timer
5. Simulates an `Enter` keypress when the timer fires
6. If another `Cmd+V` arrives before the timer fires, the timer is reset

---

## Build

```bash
chmod +x build.sh
./build.sh
```

Requires Xcode Command Line Tools (if not already installed):

```bash
xcode-select --install
```

---

## Usage

```bash
./target-autoenter
```

On first launch, macOS will require **Accessibility** permission.  
If permission is missing, the app will show an alert with the current binary path.

### Grant Accessibility permission

1. Open **System Settings**
2. Go to **Privacy & Security → Accessibility**
3. Click **+** (you may need to unlock first)
4. Add the `target-autoenter` binary
5. Make sure the toggle is enabled
6. Relaunch the app: `./target-autoenter`

> Note: macOS Accessibility permission is usually tied to the binary hash.  
> If you recompile (`./build.sh`) and it asks again, remove the old entry and re-add the new binary.

---

## Menu bar toggle

After launching, a `↩` icon appears in the menu bar.

Click it to open the menu:

- **AutoEnter**: toggle auto-send on/off
- **Quit**: quit the app

Status display:
- Enabled: icon at normal opacity
- Disabled: icon dimmed

---

## Global shortcut

Default global shortcut:

`Ctrl + Shift + Enter`

This toggles AutoEnter on/off and shows a centered HUD (`ON` / `OFF`) on screen.

### Change the shortcut

To change the shortcut, edit the shortcut check logic in `target-autoenter.m` (inside `event_callback`) and recompile.

Common modifier flags:

| Flag | Key |
|------|-----|
| `kCGEventFlagMaskControl` | Ctrl |
| `kCGEventFlagMaskShift` | Shift |
| `kCGEventFlagMaskCommand` | Cmd |
| `kCGEventFlagMaskAlternate` | Option |

---

## Toggle via script (no menu bar click needed)

```bash
./toggle.sh
```

This sends a `SIGUSR1` signal to the running app to toggle the on/off state.

---

## Customization

### 1) Auto-Enter delay (default: 500ms)

Edit the constant in `target-autoenter.m`:

```c
static const CFTimeInterval DELAY_SEC = 0.5;  // set your preferred delay (seconds)
```

Then rebuild:

```bash
./build.sh
```

Suggestions:
- If sending is sometimes too fast (text not fully pasted yet), increase to `0.6 ~ 0.8`
- If it feels too slow, decrease to `0.3 ~ 0.45`

---

## Auto-start on login (launchd)

### 1) Edit the plist file

Open `com.user.target-autoenter.plist` and replace the binary path with the actual path on your machine:

```xml
<string>/path/to/target-autoenter</string>
```

Example:

```xml
<string>/Users/andrew/Downloads/typeless-autoenter-main/target-autoenter</string>
```

### 2) Copy to LaunchAgents and load

```bash
cp com.user.target-autoenter.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.target-autoenter.plist
```

> If you modified the plist, it's safer to unload first and then load again:
>
> ```bash
> launchctl unload ~/Library/LaunchAgents/com.user.target-autoenter.plist 2>/dev/null || true
> launchctl load ~/Library/LaunchAgents/com.user.target-autoenter.plist
> ```

---

## FAQ

### 1) I already added Accessibility permission, but it still says permission is missing

This usually happens because you recompiled the binary and its hash changed. Fix it by:

- Removing the old `target-autoenter` entry from **Accessibility**
- Re-adding the newly compiled `target-autoenter`
- Running the app again

---

### 2) It pastes text but does not auto-send

Possible reasons:

- The current app uses Enter for newline instead of send
- The delay is too short and the text is not fully pasted yet (increase `DELAY_SEC`)
- AutoEnter is currently disabled (check menu bar icon / shortcut)

---

### 3) Can I make it work only in certain apps?

The current version triggers based on “target voice input process (Typeless / shandianshuo) + `Cmd+V` paste event”.  
If you want stricter app-level whitelisting (only auto-send in specific chat apps), you can extend the logic further.

---

## Acknowledgement & Attribution

This project is adapted from [ConstantineLiu/typeless-autoenter](https://github.com/ConstantineLiu/typeless-autoenter), which is licensed under the **MIT License**.

Main modifications in this repo include:

- Added support for **shandianshuo**
- Updated target process detection logic (compatible with Typeless / shandianshuo)
- Renamed binary, script, and plist to `target-autoenter`
- Adapted and validated the auto-send flow for voice-to-text paste behavior

Thanks to the original author for the idea and implementation.

---

## License

This project is released under the [MIT License](LICENSE).  
Please keep the license text and original copyright notice when redistributing or modifying.
