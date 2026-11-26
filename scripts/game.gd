class_name RedlineGame
extends Node2D
## Owns the run state. World simulation advances only in RUNNING.

enum State { MENU, RUNNING, PAUSED, OVER, STATS, SETTINGS }
const START_SPEED: float = 0.0 # Speedometer starts at zero.
const BASE_SCROLL_SPEED: float = 18.0 # Preserve the original opening road pace.

@onready var road: DesertRoad = $Road
@onready var player: PlayerCar = $Player
@onready var hazards: Node2D = $Hazards
@onready var spawner: ObstacleSpawner = $Spawner
@onready var hud: RedlineHUD = $HUD
@onready var sound: GameSound = $Sound
var data := LocalSave.new()
var state: State = State.MENU
var distance: float = 0.0
var speed: float = START_SPEED
var run_recorded: bool = true
var attract_distance: float = 0.0

func _ready() -> void:
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false
	data.load_data()
	sound.configure(data.sound_enabled, data.volume)
	hud.play_requested.connect(start_run)
	hud.menu_requested.connect(return_to_menu)
	hud.pause_requested.connect(toggle_pause)
	hud.resume_requested.connect(resume_run)
	hud.stats_requested.connect(show_stats)
	hud.settings_requested.connect(show_settings)
	hud.steer_requested.connect(steer)
	hud.sound_changed.connect(_set_sound)
	hud.volume_changed.connect(_set_volume)
	spawner.obstacle_requested.connect(_spawn_obstacle)
	hud.show_menu(data.best_distance)

static func speed_for_distance(meters: float) -> float:
	return START_SPEED + maxf(0.0, meters) * 0.018

func start_run() -> void:
	_clear_obstacles()
	player.reset()
	spawner.reset()
	distance = 0.0
	speed = START_SPEED
	run_recorded = false
	state = State.RUNNING
	road.set_distance(0.0)
	hud.show_running()
	hud.update_score(distance, data.best_distance, speed)
	sound.play_effect("click")

func _process(delta: float) -> void:
	if state == State.MENU:
		attract_distance += delta * 3.0
		road.set_distance(attract_distance)

func _physics_process(delta: float) -> void:
	if state != State.RUNNING:
		return
	# A long stalled frame should not teleport an obstacle through the player.
	var step: float = minf(delta, 0.1)
	speed = speed_for_distance(distance)
	# Displayed speed measures acceleration above the opening scrolling pace.
	var travel_speed: float = BASE_SCROLL_SPEED + speed
	var meters: float = travel_speed * step
	distance += meters
	player.advance(step)
	road.set_distance(distance)
	spawner.advance(step, travel_speed)
	for node in hazards.get_children():
		var obstacle: RoadObstacle = node
		obstacle.advance(meters)
		if obstacle.touches_player(player.position.x):
			_finish_run()
			break
		if obstacle.is_offscreen():
			obstacle.queue_free()
	hud.update_score(distance, data.best_distance, speed)
	sound.update_engine(state == State.RUNNING, travel_speed)

func steer(direction: int) -> void:
	if state != State.RUNNING:
		return
	var old_lane: int = player.lane
	player.change_lane(direction)
	if old_lane != player.lane:
		sound.play_effect("lane")

func _spawn_obstacle(lane: int, kind: int, paint: Color) -> void:
	var obstacle := RoadObstacle.new()
	obstacle.lane = lane
	obstacle.kind = kind
	obstacle.paint = paint
	hazards.add_child(obstacle)

func _clear_obstacles() -> void:
	for obstacle in hazards.get_children():
		obstacle.free()

func _record_run() -> void:
	if run_recorded:
		return
	run_recorded = true
	_check_save_result(data.record_run(distance))

func _finish_run() -> void:
	if state != State.RUNNING:
		return
	state = State.OVER
	_record_run()
	player.modulate = Color("b1a3a3")
	hud.show_over(distance, data.best_distance)
	sound.update_engine(false, speed)
	sound.play_effect("crash")

func toggle_pause() -> void:
	if state == State.PAUSED:
		resume_run()
	elif state == State.RUNNING:
		state = State.PAUSED
		hud.show_paused()
		sound.update_engine(false, speed)

func resume_run() -> void:
	if state == State.PAUSED:
		state = State.RUNNING
		hud.show_running()

func return_to_menu() -> void:
	_record_run()
	_clear_obstacles()
	player.reset()
	state = State.MENU
	hud.show_menu(data.best_distance)
	sound.update_engine(false, speed)
	sound.play_effect("click")

func show_stats() -> void:
	state = State.STATS
	hud.show_stats(data)
	sound.play_effect("click")

func show_settings() -> void:
	state = State.SETTINGS
	hud.show_settings(data)
	sound.play_effect("click")

func _set_sound(enabled: bool) -> void:
	data.sound_enabled = enabled
	sound.configure(enabled, data.volume)
	_check_save_result(data.write_data())

func _set_volume(volume: float) -> void:
	data.volume = volume
	sound.configure(data.sound_enabled, volume)
	_check_save_result(data.write_data())

func _check_save_result(error: Error) -> void:
	if error != OK:
		hud.show_save_error()
	else:
		hud.clear_save_error()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_LEFT, KEY_A: steer(-1)
		KEY_RIGHT, KEY_D: steer(1)
		KEY_P, KEY_ESCAPE: _back_or_pause()
		KEY_ENTER, KEY_SPACE:
			if state == State.MENU or state == State.OVER:
				start_run()
			elif state == State.PAUSED:
				resume_run()

func _back_or_pause() -> void:
	if state == State.RUNNING or state == State.PAUSED:
		toggle_pause()
	elif state != State.MENU:
		return_to_menu()

func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if state == State.RUNNING:
			toggle_pause()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_back_or_pause()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		_record_run()
		get_tree().quit()
