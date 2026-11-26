# Redline

A portrait Android endless highway game by **Luca Grabau**, built with **Godot 4 and GDScript** with AI assistance. Steer between three lanes, avoid traffic, barriers, and rocks, and survive for the highest distance score.

## Contents

- [Choose a setup method](#choose-a-setup-method)
- [Android compatibility](#android-compatibility)
- [Install an APK on your phone or tablet](#install-an-apk-on-your-phone-or-tablet)
- [Build an Android APK from source](#build-an-android-apk-from-source)
- [Install over USB with ADB](#install-over-usb-with-adb)
- [Controls and gameplay](#controls-and-gameplay)
- [Scores and saved data](#scores-and-saved-data)
- [Troubleshooting](#troubleshooting)
- [Run and test on a computer](#run-and-test-on-a-computer)
- [Source layout](#source-layout)

## Choose a setup method

| What you have | What to do |
| --- | --- |
| A Redline APK provided by the developer | Install it directly on Android using the steps below. No Godot or Android Studio needed on the device. |
| Only this repository | Build an APK on a computer, then transfer it to Android. |
| A computer and a USB-connected Android device | Build an APK, then use ADB to install it. |
| An iPhone or iPad | This repository has no configured or tested iOS distribution. The Android APK cannot run on iOS. |

**This repository currently contains source code, not a downloadable APK.** GitHub's **Code > Download ZIP** downloads the project source; that ZIP is not an installable Android app. Do not rename a ZIP or an AAB to APK. If an APK is published in [Releases](https://github.com/Luca-Grabau/Redline-Game/releases) later, use its release instructions.

## Android compatibility

- The checked-in Android export preset enables **ARM64 / arm64-v8a only**. An ARM64-capable Android installation is required; 32-bit-only devices and x86 emulators need a different export configuration.
- The previously tested APK reported minimum Android API **24 (Android 7.0)** and target API **36**. Check the metadata of your own export; those values depend on the export templates and settings used.
- Tested device: **Samsung Galaxy Tab S9 FE**, Android 16 / API 36.
- Rendering: Godot **Compatibility** renderer, portrait orientation, **270 × 480** internal viewport scaled to the screen.
- The game works offline and does not request Internet permission in its current preset.
- Other phones, Android versions, and unusual screen sizes have not all been tested.

## Install an APK on your phone or tablet

These steps apply once you have obtained or built a trusted Redline APK.

1. Copy `Redline-debug.apk` to the Android device, for example through USB file transfer or a download.
2. Open the device's file manager and locate the APK.
3. Tap it. If Android prevents that app from installing unknown apps, open the prompt's settings and allow installation **for that specific file manager or browser**. Settings names vary by manufacturer.
4. Return to the APK, tap **Install**, and wait for completion.
5. Tap **Open**, or find **Redline** in the app drawer.
6. Hold the device upright and tap **Play**.

You do not need Developer Options, USB debugging, Android Studio, or Godot for this file-manager installation method. After installing, you can revoke the file manager/browser's permission to install unknown apps.

A debug APK is intended for development and classroom testing. It is not a Play Store release.

## Build an Android APK from source

### 1. Download the project

Either use Git:

```sh
git clone https://github.com/Luca-Grabau/Redline-Game.git
cd Redline-Game
```

Or choose **Code > Download ZIP** on GitHub, then extract the ZIP fully to a writable folder. Keep `project.godot`, `scenes/`, `scripts/`, and `assets/` together.

### 2. Install Godot and matching export templates

The development record used **Godot 4.7.2 standard**, not the .NET editor. GDScript does not require .NET.

Use the same engine version when available. If using another Godot 4 version, treat it as an unverified configuration and check imports, scripts, and export errors before proceeding. Download engines only from the [official Godot website](https://godotengine.org/download/) or its official release archive.

In Godot, open **Editor > Manage Export Templates** and install templates that match the **exact engine version**. Android Studio does not supply Godot's export templates.

### 3. Install Java and the Android SDK

Install **OpenJDK 17** and Android Studio. Launch Android Studio and complete its initial SDK setup.

The original project setup used Android SDK Platform 35 and Build-Tools 35.0.1. Install Platform-Tools and Command-line Tools as well. If your engine version requests additional SDK, NDK, or CMake packages, follow its export diagnostics and the [official Godot Android export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html). SDK requirements can change with engine versions.

You can manage these packages in Android Studio's **SDK Manager**. A physical-device install does not require downloading an emulator system image.

Verify Java in a terminal:

```sh
java -version
javac -version
```

Both should resolve to the intended JDK installation.

### 4. Import the project and configure SDK paths

1. Open Godot's Project Manager.
2. Choose **Import** and select this repository's `project.godot`.
3. Open the project and let the initial import finish.
4. In **Editor > Editor Settings > Export > Android**, configure:
   - **Java SDK Path:** your JDK installation directory, not the `java.exe` file.
   - **Android SDK Path:** the SDK root containing `platform-tools`, not the Android Studio application directory.
5. On Windows, the SDK is commonly under `%LOCALAPPDATA%\Android\Sdk`; use the location actually shown in your SDK Manager.
6. Run the project with **F6/F5 as appropriate**: F5 runs the configured main scene. Confirm the menu loads before exporting.

SDK paths are editor settings on your computer. The repository does not configure them automatically.

### 5. Check the Android export preset

Open **Project > Export** and select the existing **Android** preset.

| Setting | Repository value |
| --- | --- |
| Package / unique name | `org.redline.runner` |
| App name | `Redline` |
| Version | `0.1.1`, version code `2` |
| CPU architecture | ARM64 enabled; ARMv7 and x86 disabled |
| Gradle build | Disabled |
| Default output | `builds/Redline-debug.apk` |
| Internet permission | Disabled |
| Android backup | Disabled |

Use a **debug export** for local testing. Godot must have a valid local debug keystore; resolve any signing warning shown in its export window. No keystores, signing passwords, or machine-specific credentials are supplied in this repository.

The project already enables `rendering/textures/vram_compression/import_etc2_astc`, which was needed for the tested Android export. Keep that setting enabled.

### 6. Export the APK

1. Create a `builds` directory in the project if it does not exist.
2. Choose **Export Project** from the Android export preset.
3. Save as `builds/Redline-debug.apk`.
4. Leave **Export With Debug** enabled for this testing build.
5. Confirm the export completes without errors.
6. Transfer the resulting APK to the device and follow the installation instructions above.

**Export PCK/ZIP is not the Android application export.** Select Export Project to produce an APK.

You can also export from the project root after configuring the editor:

```sh
godot --headless --path . --editor --import
godot --headless --path . --export-debug "Android" builds/Redline-debug.apk
```

Replace `godot` with your installed executable's name or full path. On Windows PowerShell, a quoted executable path must be invoked with `&`:

```powershell
New-Item -ItemType Directory -Force builds | Out-Null
& "C:\path\to\Godot_console.exe" --headless --path . --export-debug "Android" "builds/Redline-debug.apk"
```

## Install over USB with ADB

ADB is an alternative to copying the APK manually.

1. On Android, enable Developer Options. Many devices expose this by tapping **Build number** repeatedly in Settings; location varies.
2. Enable **USB debugging**.
3. Connect the device with a USB cable that supports data.
4. Unlock it and approve the USB-debugging prompt for your computer.
5. Run ADB from the Android SDK's `platform-tools` directory, or add that directory to PATH.

```sh
adb devices -l
adb install -r builds/Redline-debug.apk
adb shell monkey -p org.redline.runner -c android.intent.category.LAUNCHER 1
```

Expected results:

- `adb devices -l` lists your device with status `device`.
- Installation reports `Success`.
- Redline opens to its menu.

For several connected devices, select one explicitly:

```sh
adb -s YOUR_DEVICE_SERIAL install -r builds/Redline-debug.apk
```

The `-r` option requests an update that keeps existing app data, provided the package, signing key, and Android's update rules are compatible.

Example Windows command if ADB is not on PATH:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices -l
```

When finished, USB debugging can be disabled. It is not required for normal gameplay.

## Controls and gameplay

| Action | Android | Computer |
| --- | --- | --- |
| Start | Tap Play | Enter/Space from the menu, or click Play |
| Change lane | Tap left/right steering buttons | Left/Right arrows or A/D |
| Pause | Tap Pause | P or Escape |
| Resume | Tap Resume | Enter/Space, P, or Escape while paused |
| Retry after collision | Tap Retry | Enter/Space |
| Return from another screen | Use the menu controls | Escape/P follows the screen's back behavior |

- Dodge traffic, barriers, and rocks.
- Each steering input changes the destination by one lane; the car moves there smoothly.
- Score measures **distance traveled**, not the speedometer reading.
- Displayed speed starts at zero while the road already scrolls. This is intentional.
- Travel speed increases without a maximum cap. Spawn intervals shorten over their configured range, then remain bounded separately.
- Leaving the app or losing focus during a run automatically pauses it.
- Android's Back action pauses/resumes an active run or returns from another screen to the menu.
- Settings control sound and volume. Statistics show stored run totals.

## Scores and saved data

Best distance, total distance, run count, and settings are stored locally in Godot's `user://redline.json` location, inside the app's private storage. No account or cloud service is used.

Runs are recorded when they finish or when you leave them through the game's menu. Force-stopping the process mid-run may lose the unrecorded run's progress.

A temporary file and previous-save backup support recovery from a damaged main save. This is local recovery, not cloud backup. Uninstalling the app or clearing its app storage removes its local scores/settings.

A visible storage warning means the app could not save; do not assume that run's results were retained.

## Troubleshooting

| Problem | What to check |
| --- | --- |
| Downloaded ZIP will not install | It is source code. Extract it on a computer and export an APK. |
| No APK in the repository | Build one using the instructions above, or obtain a developer-provided APK. |
| Device says app is incompatible / `NO_MATCHING_ABIS` | The preset exports ARM64 only. Check the device's Android ABI; an x86 emulator or 32-bit-only device needs a different build. |
| `adb devices` shows `unauthorized` | Unlock the device and approve the computer's USB-debugging prompt. |
| Device not listed | Try a data-capable cable/another USB port, enable debugging, and check manufacturer USB drivers on Windows. |
| Device is `offline` | Reconnect and reauthorize; if needed, run `adb kill-server`, then `adb start-server`, then list devices again. |
| Missing export templates | Install templates matching your exact Godot version through Manage Export Templates. |
| SDK/JDK validation fails | Verify Godot's Java SDK and Android SDK paths and install the packages its export dialog requests. |
| Texture-compression export error | Ensure ETC2/ASTC texture import is enabled in Project Settings, then reimport and export again. |
| Signing/debug-keystore error | Configure a valid local debug keystore through Godot's Android export/editor settings. Do not use missing paths from another machine. |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | An installed app uses the same package but a different signing key. Use the original key, or uninstall the conflicting app first; uninstalling erases its local data. |
| `INSTALL_FAILED_VERSION_DOWNGRADE` | Build with an appropriate higher version code, or deliberately remove the newer installed build first if losing its local data is acceptable. |
| App opens but seems frozen | Check for the pause screen after switching apps; tap Resume. |
| No sound | Check in-game sound/volume and the device's media volume. |
| Scores disappear after reinstall | Uninstalling or clearing app storage removes local data; there is no cloud restore. |

For crashes or script errors, reproduce the issue and inspect Android Studio Logcat or:

```sh
adb logcat
```

Filter for the app's process/package or Godot messages. Include the device model, Android version, engine version, build steps, and relevant error text when reporting a problem.

## Run and test on a computer

Open `project.godot` in Godot and press **F5**. The game uses a portrait window and supports keyboard controls for quick checks before Android export.

From the project root:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/test_core.gd
godot --headless --path . --script res://tests/test_road.gd
```

Expected results for the uploaded version: **24 core checks** and **4 road checks**, with **zero failures**. Core tests use separate save files rather than the normal player save.

These assertions cover saves, spawning, collision, steering, pause/retry, settings, and progression. They do not replace physical-device checks for touch, audio, installation, and Android lifecycle behavior. Android-only changes should be checked on a real device.

## Source layout

| Path | Responsibility |
| --- | --- |
| `project.godot` | Project settings and main-scene selection |
| `export_presets.cfg` | Android export configuration |
| `scenes/game.tscn` | Main game scene |
| `scripts/game.gd` | Run state, progression, controls, and module coordination |
| `scripts/player.gd` | Smooth three-lane steering |
| `scripts/road.gd` | Desert drawing and shared perspective |
| `scripts/spawner.gd` | Timed randomized obstacle requests |
| `scripts/obstacle.gd` | Obstacle motion, projection, and collision |
| `scripts/save.gd` | Local score/settings persistence and validation |
| `scripts/hud.gd` | Menus, touch buttons, settings, and statistics |
| `scripts/art.gd` | Procedural pixel sprites |
| `scripts/sound.gd` | Synthesized sound effects and engine audio |
| `assets/icon.svg` | Project/app icon source |
| `tests/` | Automated core and projection checks |

The developer's local `tools/godot.ps1` launcher is not included in this repository. Use your own Godot executable and the commands above. Generated APKs, engine import caches, and signing credentials are intentionally excluded from source control.

## Distribution notes

This is a classroom/development project with a tested debug Android build. Google Play distribution requires separate release signing and store preparation. No iOS export preset or iOS test results are included.

Official setup references: [Godot Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [Android Studio](https://developer.android.com/studio), and [Android ADB guide](https://developer.android.com/tools/adb).
