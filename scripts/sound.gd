class_name GameSound
extends Node
## Tiny synthesized sounds keep the project self-contained.

var enabled: bool = true
var effect := AudioStreamPlayer.new()
var engine := AudioStreamPlayer.new()
var lane_sound: AudioStreamWAV
var click_sound: AudioStreamWAV
var crash_sound: AudioStreamWAV

func _ready() -> void:
	add_child(effect)
	add_child(engine)
	effect.volume_db = -10.0
	engine.volume_db = -29.0
	lane_sound = _tone(220.0, 0.07)
	click_sound = _tone(660.0, 0.06)
	crash_sound = _tone(65.0, 0.35, true)
	engine.stream = _tone(80.0, 0.5)
	engine.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	engine.stream.loop_begin = 0
	engine.stream.loop_end = 11025

static func _tone(frequency: float, seconds: float, noise: bool = false) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count: int = int(22050.0 * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for i in range(count):
		var t: float = float(i) / float(count)
		var wave: float = rng.randf_range(-1.0, 1.0) if noise else sin(TAU * frequency * float(i) / 22050.0)
		var envelope: float = (1.0 - t) * (1.0 - t)
		data.encode_s16(i * 2, int(wave * envelope * 18000.0))
	stream.data = data
	return stream

func configure(sound_on: bool, volume: float) -> void:
	enabled = sound_on
	AudioServer.set_bus_mute(0, not sound_on)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.001, volume)))
	if not enabled:
		engine.stop()
		effect.stop()

func play_effect(which: String) -> void:
	# Headless tests have no sound device; do not queue silent playbacks there.
	if not enabled or AudioServer.get_driver_name() == "Dummy":
		return
	effect.stream = crash_sound if which == "crash" else (lane_sound if which == "lane" else click_sound)
	effect.play()

func update_engine(running: bool, speed: float) -> void:
	if not enabled or not running or AudioServer.get_driver_name() == "Dummy":
		engine.stop()
		return
	engine.pitch_scale = lerpf(0.9, 1.8, clampf((speed - 18.0) / 28.0, 0.0, 1.0))
	if not engine.playing:
		engine.play()
