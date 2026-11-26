class_name ObstacleSpawner
extends Node
## One obstacle per wave always leaves two open lanes. No all-lane walls.

signal obstacle_requested(lane: int, kind: int, paint: Color)
const PAINTS: Array[Color] = [Color("38adad"), Color("e6b64f"), Color("7e79c7")]
var rng := RandomNumberGenerator.new()
var countdown: float = 0.6

func _ready() -> void:
	rng.randomize()

func reset() -> void:
	countdown = 0.6

static func interval_for_speed(speed: float) -> float:
	return lerpf(1.55, 0.86, clampf((speed - 18.0) / 28.0, 0.0, 1.0))

func advance(delta: float, speed: float) -> void:
	countdown -= delta
	if countdown <= 0.0:
		var lane: int = rng.randi_range(0, 2)
		var kind: int = rng.randi_range(0, 2)
		obstacle_requested.emit(lane, kind, PAINTS[rng.randi_range(0, 2)])
		countdown += interval_for_speed(speed) * rng.randf_range(0.9, 1.1)
