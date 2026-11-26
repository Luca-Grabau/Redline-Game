class_name PlayerCar
extends Node2D
## Destination lane and displayed position are separate during a lane change.

const LANE_X: Array[float] = [57.0, 135.0, 213.0]
const STEER_SPEED: float = 520.0
const HALF_WIDTH: float = 18.0
var lane: int = 1

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = PixelArt.car(Color("ed3e37"), true)
	sprite.centered = false
	sprite.position = Vector2(-28, -40)
	add_child(sprite)
	z_index = 100
	reset()

func change_lane(direction: int) -> void:
	if direction != -1 and direction != 1:
		return
	lane = clampi(lane + direction, 0, 2)

func advance(delta: float) -> void:
	position.x = move_toward(position.x, LANE_X[lane], STEER_SPEED * delta)

func reset() -> void:
	lane = 1
	position = Vector2(LANE_X[lane], 374.0)
	modulate = Color.WHITE
