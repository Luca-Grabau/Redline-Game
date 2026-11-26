class_name RedlineHUD
extends CanvasLayer
## All screens use the same 270 by 480 canvas and a small shared theme.

signal play_requested
signal menu_requested
signal pause_requested
signal resume_requested
signal stats_requested
signal settings_requested
signal steer_requested(direction: int)
signal sound_changed(enabled: bool)
signal volume_changed(value: float)

var root: Control
var shade: ColorRect
var top: Control
var touch_controls: Control
var menu: Control
var paused: Control
var over: Control
var stats: Control
var settings: Control
var score_label: Label
var best_label: Label
var speed_label: Label
var menu_best: Label
var result_score: Label
var result_best: Label
var stats_values: Label
var sound_toggle: CheckButton
var volume_slider: HSlider
var notice: Label
var has_save_error: bool = false

func _ready() -> void:
	root = Control.new()
	root.size = Vector2(270, 480)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Theme.new()
	root.theme.default_font_size = 13
	root.theme.set_color("font_color", "Label", Color("f7efd9"))
	add_child(root)
	shade = ColorRect.new()
	shade.size = root.size
	shade.color = Color(0.025, 0.045, 0.09, 0.38)
	root.add_child(shade)
	_build_top()
	_build_menu()
	_build_pause()
	_build_over()
	_build_stats()
	_build_settings()
	notice = _label("", Rect2(15, 388, 240, 15), 10, root, true)
	notice.add_theme_color_override("font_color", Color("ffd268"))
	_hide_all()

func _group() -> Control:
	var group := Control.new()
	group.size = root.size
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(group)
	return group

func _style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("879ab0")
	style.set_border_width_all(2)
	return style

func _panel(rect: Rect2, parent: Control) -> void:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(Color("162237f2")))
	parent.add_child(panel)

func _label(text: String, rect: Rect2, font_size: int, parent: Control, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(text: String, rect: Rect2, parent: Control, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 16 if primary else 13)
	var color: Color = Color("c33d38") if primary else Color("26394e")
	button.add_theme_stylebox_override("normal", _style(color))
	button.add_theme_stylebox_override("hover", _style(color.lightened(0.15)))
	button.add_theme_stylebox_override("pressed", _style(color.darkened(0.2)))
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _build_top() -> void:
	top = _group()
	_panel(Rect2(8, 8, 254, 50), top)
	score_label = _label("0 m", Rect2(15, 11, 129, 25), 19, top)
	best_label = _label("BEST 0 m", Rect2(15, 36, 139, 14), 10, top)
	speed_label = _label("65", Rect2(150, 12, 65, 25), 19, top, true)
	_label("KM/H", Rect2(150, 37, 65, 12), 9, top, true)
	_button("II", Rect2(229, 16, 25, 32), top, func(): pause_requested.emit())
	touch_controls = _group()
	var left := _button("<", Rect2(12, 408, 88, 55), touch_controls, func(): pass)
	var right := _button(">", Rect2(170, 408, 88, 55), touch_controls, func(): pass)
	left.add_theme_font_size_override("font_size", 30)
	right.add_theme_font_size_override("font_size", 30)
	left.button_down.connect(func(): steer_requested.emit(-1))
	right.button_down.connect(func(): steer_requested.emit(1))
	_label("LEFT", Rect2(12, 465, 88, 12), 9, touch_controls, true)
	_label("RIGHT", Rect2(170, 465, 88, 12), 9, touch_controls, true)

func _build_menu() -> void:
	menu = _group()
	_label("REDLINE", Rect2(15, 79, 240, 46), 35, menu, true)
	_label("DESERT HIGHWAY", Rect2(15, 126, 240, 19), 12, menu, true)
	menu_best = _label("BEST 0 m", Rect2(15, 164, 240, 20), 13, menu, true)
	_button("PLAY", Rect2(45, 210, 180, 43), menu, func(): play_requested.emit(), true)
	_button("STATS", Rect2(45, 265, 86, 34), menu, func(): stats_requested.emit())
	_button("SETTINGS", Rect2(139, 265, 86, 34), menu, func(): settings_requested.emit())
	_label("Tap arrows to change lanes", Rect2(20, 303, 230, 17), 11, menu, true)
	_label("Desktop: A/D or arrow keys", Rect2(20, 321, 230, 12), 9, menu, true)
	_label("CPSC 332  /  Luca Grabau", Rect2(15, 451, 240, 17), 9, menu, true)

func _build_pause() -> void:
	paused = _group()
	_panel(Rect2(25, 164, 220, 183), paused)
	_label("PAUSED", Rect2(35, 180, 200, 36), 25, paused, true)
	_button("RESUME", Rect2(45, 233, 180, 41), paused, func(): resume_requested.emit(), true)
	_button("MAIN MENU", Rect2(45, 288, 180, 35), paused, func(): menu_requested.emit())

func _build_over() -> void:
	over = _group()
	_panel(Rect2(20, 127, 230, 232), over)
	_label("WRECKED", Rect2(30, 141, 210, 39), 27, over, true)
	result_score = _label("0 m", Rect2(30, 186, 210, 32), 24, over, true)
	result_best = _label("BEST 0 m", Rect2(30, 222, 210, 20), 12, over, true)
	_button("RETRY", Rect2(45, 260, 180, 40), over, func(): play_requested.emit(), true)
	_button("MAIN MENU", Rect2(45, 312, 180, 32), over, func(): menu_requested.emit())

func _build_stats() -> void:
	stats = _group()
	_panel(Rect2(20, 141, 230, 220), stats)
	_label("STATISTICS", Rect2(30, 158, 210, 32), 21, stats, true)
	stats_values = _label("", Rect2(38, 203, 194, 96), 14, stats)
	_button("BACK", Rect2(45, 312, 180, 34), stats, func(): menu_requested.emit())

func _build_settings() -> void:
	settings = _group()
	_panel(Rect2(20, 144, 230, 216), settings)
	_label("SETTINGS", Rect2(30, 159, 210, 32), 23, settings, true)
	sound_toggle = CheckButton.new()
	sound_toggle.text = "Sound"
	sound_toggle.position = Vector2(36, 208)
	sound_toggle.size = Vector2(198, 33)
	sound_toggle.focus_mode = Control.FOCUS_NONE
	sound_toggle.toggled.connect(func(on: bool): sound_changed.emit(on))
	settings.add_child(sound_toggle)
	_label("VOLUME", Rect2(38, 252, 194, 20), 10, settings)
	volume_slider = HSlider.new()
	volume_slider.position = Vector2(38, 276)
	volume_slider.size = Vector2(194, 20)
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.focus_mode = Control.FOCUS_NONE
	volume_slider.value_changed.connect(func(value: float): volume_changed.emit(value))
	settings.add_child(volume_slider)
	_button("BACK", Rect2(45, 316, 180, 32), settings, func(): menu_requested.emit())

func _hide_all() -> void:
	for child in root.get_children():
		child.hide()
	# Screen transitions must not hide an unresolved storage failure.
	if has_save_error and is_instance_valid(notice):
		notice.show()

func show_menu(best: float) -> void:
	_hide_all()
	shade.show()
	menu.show()
	menu_best.text = "BEST %d m" % int(best)

func show_running() -> void:
	_hide_all()
	top.show()
	touch_controls.show()

func show_paused() -> void:
	_hide_all()
	shade.show()
	top.show()
	paused.show()

func show_over(distance: float, best: float) -> void:
	_hide_all()
	shade.show()
	top.show()
	over.show()
	result_score.text = "%d m" % int(distance)
	result_best.text = "BEST %d m" % int(best)

func show_stats(data: LocalSave) -> void:
	_hide_all()
	shade.show()
	stats.show()
	stats_values.text = "BEST     %d m\n\nTOTAL    %.2f km\n\nRUNS     %d" % [
		int(data.best_distance), data.total_distance / 1000.0, data.runs]

func show_settings(data: LocalSave) -> void:
	_hide_all()
	shade.show()
	settings.show()
	sound_toggle.set_pressed_no_signal(data.sound_enabled)
	volume_slider.set_value_no_signal(data.volume)

func update_score(distance: float, best: float, speed: float) -> void:
	score_label.text = "%d m" % int(distance)
	best_label.text = "BEST %d m" % int(maxf(distance, best))
	speed_label.text = "%d" % int(speed * 3.6)

func show_save_error() -> void:
	has_save_error = true
	notice.text = "Unable to save progress"
	notice.show()

func clear_save_error() -> void:
	has_save_error = false
	notice.hide()
