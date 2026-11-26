class_name DesertRoad
extends Node2D
## Pixel desert and perspective road. All distances are in simulated meters.
## Player and obstacles will share project_point so their lanes line up.

const LOOK_AHEAD: float = 120.0
const HORIZON: float = 178.0
const NEAR_Y: float = 374.0
var distance: float = 0.0

static func project_point(lane: float, z: float) -> Vector2:
	# t grows as an object approaches; squaring makes it accelerate visually.
	var t: float = clampf(1.0 - z / LOOK_AHEAD, 0.0, 1.3)
	var depth: float = t * t
	return Vector2(135.0 + (lane - 1.0) * (8.0 + 70.0 * depth),
		HORIZON + (NEAR_Y - HORIZON) * depth)

static func project_scale(z: float) -> float:
	var t: float = clampf(1.0 - z / LOOK_AHEAD, 0.0, 1.3)
	return 0.08 + 0.92 * t * t

func set_distance(meters: float) -> void:
	distance = meters
	queue_redraw()

func _draw() -> void:
	# Broad flat bands and stepped silhouettes keep the landscape legible.
	draw_rect(Rect2(0, 0, 270, 480), Color("efa84e"))
	draw_rect(Rect2(0, 0, 270, 118), Color("398cda"))
	draw_rect(Rect2(0, 118, 270, 60), Color("69b9df"))
	draw_rect(Rect2(210, 68, 28, 32), Color("ffdc79"))
	draw_rect(Rect2(206, 76, 36, 16), Color("ffdc79"))
	_cloud(Vector2(27, 69), 1.0)
	_cloud(Vector2(137, 36), 0.7)
	_mesa(PackedVector2Array([Vector2(0, 178), Vector2(0, 109),
		Vector2(16, 109), Vector2(16, 93), Vector2(33, 93),
		Vector2(33, 103), Vector2(40, 103), Vector2(40, 146),
		Vector2(57, 146), Vector2(57, 164), Vector2(89, 178)]))
	_mesa(PackedVector2Array([Vector2(180, 178), Vector2(203, 162),
		Vector2(216, 162), Vector2(216, 131), Vector2(231, 131),
		Vector2(231, 117), Vector2(257, 117), Vector2(257, 142),
		Vector2(270, 142), Vector2(270, 178)]))
	draw_rect(Rect2(19, 105, 5, 47), Color("e88639"))
	draw_rect(Rect2(238, 127, 5, 33), Color("e88639"))
	# Each two-pixel strip samples the same depth that obstacles use.
	for y in range(int(HORIZON), 480, 2):
		var depth: float = float(y - HORIZON) / (NEAR_Y - HORIZON)
		var half_width: float = 12.0 + 105.0 * depth
		var z: float = LOOK_AHEAD * (1.0 - sqrt(depth))
		var stripe: bool = posmod(int(floor((z + distance) / 7.0)), 2) == 0
		var shoulder: Color = Color("e7d9b2") if stripe else Color("bb543c")
		draw_rect(Rect2(135 - half_width - 4, y, half_width * 2 + 8, 2), shoulder)
		draw_rect(Rect2(135 - half_width, y, half_width * 2, 2), Color("41485c"))
		if stripe:
			var width: float = maxf(1.0, 2.0 * depth)
			for side in [-1.0, 1.0]:
				draw_rect(Rect2(135 + side * half_width / 3.0 - width / 2.0,
					y, width, 2), Color("f3ebcf"))
	# Decorative cacti sit outside both shoulders and repeat with distance.
	for i in range(8):
		var z: float = fposmod(float(i) * 19.0 - distance, 150.0) - 15.0
		var scale_factor: float = project_scale(z)
		var side: float = -1.0 if i % 2 == 0 else 1.0
		var point: Vector2 = project_point(1.0 + side * 2.2, z)
		_cactus(point, scale_factor)

func _mesa(points: PackedVector2Array) -> void:
	draw_colored_polygon(points, Color("ac614e"))

func _cloud(at: Vector2, s: float) -> void:
	draw_rect(Rect2(at, Vector2(44, 5) * s), Color("f6e9cf"))
	draw_rect(Rect2(at + Vector2(9, -6) * s, Vector2(27, 7) * s), Color("f6e9cf"))
	draw_rect(Rect2(at + Vector2(17, -12) * s, Vector2(11, 7) * s), Color("f6e9cf"))

func _cactus(at: Vector2, s: float) -> void:
	var green: Color = Color("297957")
	draw_rect(Rect2(at + Vector2(-2, -23) * s, Vector2(4, 23) * s), green)
	draw_rect(Rect2(at + Vector2(-7, -15) * s, Vector2(3, 9) * s), green)
	draw_rect(Rect2(at + Vector2(4, -19) * s, Vector2(3, 10) * s), green)
	draw_rect(Rect2(at + Vector2(-6, -9) * s, Vector2(11, 3) * s), green)
