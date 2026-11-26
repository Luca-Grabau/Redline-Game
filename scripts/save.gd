class_name LocalSave
extends RefCounted
## JSON lives in Godot's writable application directory, not in the APK.
## Tests can pass a separate path so they never overwrite the player's save.

var path: String
var best_distance: float = 0.0
var total_distance: float = 0.0
var runs: int = 0
var sound_enabled: bool = true
var volume: float = 0.65

func _init(save_path: String = "user://redline.json") -> void:
	path = save_path

func load_data() -> void:
	if not _load_file(path):
		_load_file(path + ".bak")

static func _safe_number(data: Dictionary, key: String, fallback: float, maximum: float) -> float:
	var value: Variant = data.get(key, fallback)
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return fallback
	var number: float = float(value)
	if not is_finite(number) or number < 0.0:
		return fallback
	return minf(number, maximum)

func _load_file(filename: String) -> bool:
	if not FileAccess.file_exists(filename):
		return false
	var file := FileAccess.open(filename, FileAccess.READ)
	if file == null:
		return false
	var parser := JSON.new()
	var error: Error = parser.parse(file.get_as_text())
	file.close()
	if error != OK or not parser.data is Dictionary:
		return false
	var data: Dictionary = parser.data
	if data.get("version", 0) != 1:
		return false
	best_distance = _safe_number(data, "best_distance", 0.0, 1.0e12)
	total_distance = _safe_number(data, "total_distance", 0.0, 1.0e15)
	runs = int(_safe_number(data, "runs", 0.0, 1.0e9))
	sound_enabled = data.get("sound_enabled", true) if data.get("sound_enabled", true) is bool else true
	volume = clampf(_safe_number(data, "volume", 0.65, 1.0), 0.0, 1.0)
	return true

func record_run(meters: float) -> Error:
	if not is_finite(meters) or meters < 0.0:
		return ERR_INVALID_PARAMETER
	best_distance = maxf(best_distance, meters)
	total_distance += meters
	runs += 1
	return write_data()

func write_data() -> Error:
	var temporary: String = path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version": 1,
		"best_distance": best_distance, "total_distance": total_distance,
		"runs": runs, "sound_enabled": sound_enabled, "volume": volume}))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		return error
	# Keep the previous valid file available if the main file is damaged later.
	if FileAccess.file_exists(path):
		error = DirAccess.copy_absolute(path, path + ".bak")
		if error != OK:
			return error
	return DirAccess.rename_absolute(temporary, path)
