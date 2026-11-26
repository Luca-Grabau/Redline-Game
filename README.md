# Redline

Android endless highway game by Luca Grabau, developed with Godot 4 and GDScript with AI assistance.

## Run

Open `project.godot` in Godot 4.7.2 and run the main scene. Use Left/Right or A/D to steer; Escape/P pauses. Android builds use touch buttons.

Includes smooth three-lane steering, randomized hazards, collision detection, increasing speed, distance scoring, pause/retry, sound settings, and local save data.

## Tests

Run `godot --headless --path . --script res://tests/test_core.gd` and `godot --headless --path . --script res://tests/test_road.gd`.

The production version passed 24 core checks and four road checks and was tested on a Samsung Galaxy Tab S9 FE. Android export uses the Android preset and requires local Android SDK, JDK, and Godot export templates. Signing credentials and generated builds are not included.
