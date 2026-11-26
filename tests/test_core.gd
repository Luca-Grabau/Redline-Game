extends SceneTree
## Runs production scene/scripts with an isolated save, never the player save.

const GameScene = preload("res://scenes/game.tscn")
var failures: int = 0
var checks: int = 0
var test_prefix: String

func check(condition: bool, label: String) -> void:
	checks += 1
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	DirAccess.make_dir_recursive_absolute("user://automated-tests")
	test_prefix = "user://automated-tests/%d" % Time.get_ticks_usec()
	_test_save()
	_test_spawner()
	_test_collisions()
	var game: RedlineGame = GameScene.instantiate()
	game.data = LocalSave.new(test_prefix + "-game.json")
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	check(game.state == RedlineGame.State.MENU and game.hud.menu.visible,
		"G01 main menu opens before a run")
	game.start_run()
	game.spawner.countdown = 999.0
	check(game.speed == 0.0 and game.hud.speed_label.text == "0",
		"G00a new run starts with zero on the speedometer")
	game._physics_process(1.0 / 60.0)
	check(is_equal_approx(game.distance, 0.3),
		"G00b first frame preserves the original 18 m/s scrolling and distance pace")
	for i in range(120):
		game._physics_process(1.0 / 60.0)
	check(game.distance > 36.0 and game.speed > RedlineGame.START_SPEED,
		"G02 two simulated seconds advance score and increase speed")
	var left_event := InputEventKey.new()
	left_event.physical_keycode = KEY_LEFT
	left_event.pressed = true
	game._unhandled_key_input(left_event)
	game.player.advance(0.01)
	check(game.player.lane == 0 and game.player.position.x > 57.0
		and game.player.position.x < 135.0,
		"G03 keyboard steering changes destination and moves smoothly")
	for i in range(30):
		game._physics_process(1.0 / 60.0)
	game.steer(-1)
	game.steer(999)
	check(is_equal_approx(game.player.position.x, 57.0) and game.player.lane == 0,
		"G04 edge: repeated left at lane zero and invalid directions stay on road")
	game.toggle_pause()
	var paused_distance: float = game.distance
	var paused_timer: float = game.spawner.countdown
	game.steer(1)
	for i in range(120):
		game._physics_process(1.0 / 60.0)
	check(game.distance == paused_distance and game.spawner.countdown == paused_timer
		and game.player.lane == 0 and game.hud.paused.visible,
		"G05 pause freezes score, spawning, and steering")
	game.resume_run()
	game._physics_process(1.0 / 60.0)
	check(game.state == RedlineGame.State.RUNNING and game.distance > paused_distance,
		"G06 resume continues the same run")
	game.distance = 2000.0
	var previous_distance: float = game.distance
	game._physics_process(1.0 / 60.0)
	check(game.distance - previous_distance > 46.0 / 60.0,
		"G06b later runs physically scroll faster than the former 46 m/s cap")
	game.start_run()
	game.spawner.countdown = 999.0
	game._spawn_obstacle(1, 0, Color.WHITE)
	var obstacle: RoadObstacle = game.hazards.get_child(0)
	obstacle.z = 6.0
	var old_runs: int = game.data.runs
	game._physics_process(1.0 / 60.0)
	game._finish_run()
	check(game.state == RedlineGame.State.OVER and game.hud.over.visible
		and game.data.runs == old_runs + 1,
		"G07 collision shows game over and records exactly one run")
	game.return_to_menu()
	check(game.data.runs == old_runs + 1 and game.hazards.get_child_count() == 0,
		"G08 menu return clears hazards without recording a run twice")
	game.start_run()
	check(game.distance == 0.0 and game.player.lane == 1
		and game.player.position == Vector2(135, 374),
		"G09 retry resets score, speed, player position, and hazards")
	game.return_to_menu()
	game.show_settings()
	game._set_sound(false)
	game._set_volume(0.2)
	var reloaded := LocalSave.new(game.data.path)
	reloaded.load_data()
	check(not reloaded.sound_enabled and is_equal_approx(reloaded.volume, 0.2)
		and AudioServer.is_bus_mute(0),
		"G10 sound mute and volume persist to a fresh save object")
	game.return_to_menu()
	game.show_stats()
	check(game.hud.stats.visible and "TOTAL" in game.hud.stats_values.text,
		"G11 statistics screen exposes distance and run totals")
	game.start_run()
	game.data.path = test_prefix + "-missing-parent/save.json"
	game.distance = 25.0
	game._finish_run()
	check(game.hud.notice.visible,
		"G12 edge: failed storage displays an error on the game-over screen")
	game.free()
	# Audio releases playback references on its mixing thread, not this call stack.
	await create_timer(0.12).timeout
	print("CORE TESTS: %d checks; %d failure(s)" % [checks, failures])
	quit(0 if failures == 0 else 1)

func _test_save() -> void:
	var save := LocalSave.new(test_prefix + "-save.json")
	save.load_data()
	check(save.best_distance == 0.0 and save.runs == 0,
		"S01 missing save starts with defaults")
	var first: Error = save.record_run(42.75)
	var second: Error = save.record_run(10.0)
	var loaded := LocalSave.new(save.path)
	loaded.load_data()
	check(first == OK and second == OK and is_equal_approx(loaded.best_distance, 42.75)
		and is_equal_approx(loaded.total_distance, 52.75) and loaded.runs == 2,
		"S02 runs preserve best and accumulate total across reload")
	check(save.record_run(-1.0) == ERR_INVALID_PARAMETER and save.runs == 2,
		"S03 edge: negative distance is rejected without changing statistics")
	var corrupt := FileAccess.open(save.path, FileAccess.WRITE)
	corrupt.store_string("{broken json")
	corrupt.close()
	var recovered := LocalSave.new(save.path)
	recovered.load_data()
	check(recovered.runs == 1 and is_equal_approx(recovered.total_distance, 42.75),
		"S04 damaged main save recovers the previous valid backup")
	var invalid := FileAccess.open(test_prefix + "-invalid.json", FileAccess.WRITE)
	invalid.store_string(JSON.stringify({"version": 1, "best_distance": -9,
		"total_distance": "bad", "runs": -4, "volume": 999, "sound_enabled": "yes"}))
	invalid.close()
	var sanitized := LocalSave.new(test_prefix + "-invalid.json")
	sanitized.load_data()
	check(sanitized.best_distance == 0.0 and sanitized.total_distance == 0.0
		and sanitized.runs == 0 and sanitized.volume == 1.0 and sanitized.sound_enabled,
		"S05 edge: malformed field types and out-of-range values use safe defaults")

func _test_spawner() -> void:
	var spawner := ObstacleSpawner.new()
	root.add_child(spawner)
	spawner.rng.seed = 104
	var waves: Array[Vector2i] = []
	spawner.obstacle_requested.connect(func(lane: int, kind: int, _paint: Color):
		waves.append(Vector2i(lane, kind)))
	for i in range(1800):
		spawner.advance(1.0 / 60.0, 18.0)
	var slow_count: int = waves.size()
	waves.clear()
	spawner.reset()
	for i in range(1800):
		spawner.advance(1.0 / 60.0, 46.0)
	var valid: bool = true
	var kinds: Dictionary = {}
	for wave in waves:
		valid = valid and wave.x >= 0 and wave.x <= 2 and wave.y >= 0 and wave.y <= 2
		kinds[wave.y] = true
	check(waves.size() > slow_count and valid and kinds.size() == 3,
		"P01 seeded waves use valid lanes, include all hazard types, and grow more frequent")
	check(RedlineGame.speed_for_distance(10000.0) > RedlineGame.speed_for_distance(5000.0)
		and ObstacleSpawner.interval_for_speed(1.0e12) >= 0.8,
		"P02 speed keeps increasing past the old cap while spawn timing stays bounded")
	spawner.free()

func _test_collisions() -> void:
	var obstacle := RoadObstacle.new()
	obstacle.lane = 1
	obstacle.kind = 0
	obstacle.previous_z = 20.0
	obstacle.z = -20.0
	check(obstacle.touches_player(135.0) and not obstacle.touches_player(57.0),
		"C01 swept depth detects a fast crossing but leaves neighboring lane safe")
	obstacle.previous_z = 100.0
	obstacle.z = 90.0
	check(not obstacle.touches_player(135.0),
		"C02 a distant obstacle cannot collide with the player")
	obstacle.free()
