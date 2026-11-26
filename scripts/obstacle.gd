class_name RoadObstacle
extends Node2D
## z is distance ahead of the player. Smaller z means nearer the camera.

const HALF_WIDTHS: Array[float] = [16.0, 22.0, 12.0]
var lane: int = 1
var kind: int = 0 # 0: traffic, 1: barrier, 2: rock.
var z: float = 120.0
var previous_z: float = 120.0
var paint: Color = Color("38adad")

func _ready() -> void:
	var sprite := Sprite2D.new()
	match kind:
		0: sprite.texture = PixelArt.car(paint)
		1: sprite.texture = PixelArt.barrier()
		2: sprite.texture = PixelArt.rock()
	sprite.centered = false
	sprite.position = Vector2(-sprite.texture.get_width() / 2.0, -sprite.texture.get_height())
	add_child(sprite)
	_refresh_projection()

func advance(meters: float) -> void:
	previous_z = z
	z -= meters
	_refresh_projection()

func _refresh_projection() -> void:
	position = DesertRoad.project_point(float(lane), z)
	scale = Vector2.ONE * DesertRoad.project_scale(z)
	z_index = int(100.0 - z)

func touches_player(player_x: float) -> bool:
	# Sweep across the contact interval so a fast step cannot skip collision.
	if previous_z < -4.0 or z > 7.0:
		return false
	var lane_center: float = DesertRoad.project_point(float(lane), 0.0).x
	return absf(player_x - lane_center) < PlayerCar.HALF_WIDTH + HALF_WIDTHS[kind]

func is_offscreen() -> bool:
	return z < -32.0
