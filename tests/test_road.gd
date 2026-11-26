extends SceneTree
## Deterministic checks for the shared road/obstacle perspective.
## These tests exercise the production script, not a duplicate implementation.

const Road = preload("res://scripts/road.gd")
var failures: int = 0

func check(condition: bool, test_name: String) -> void:
	print(("PASS " if condition else "FAIL ") + test_name)
	if not condition:
		failures += 1

func _initialize() -> void:
	check(Road.project_point(0.0, 0.0).is_equal_approx(Vector2(57, 374))
		and Road.project_point(1.0, 0.0).is_equal_approx(Vector2(135, 374))
		and Road.project_point(2.0, 0.0).is_equal_approx(Vector2(213, 374)),
		"R01 near-plane lane positions match the proposed steering coordinates")
	check(Road.project_point(1.0, 120.0).is_equal_approx(Vector2(135, 178))
		and is_equal_approx(Road.project_scale(0.0), 1.0),
		"R02 far objects start at the horizon; near sprites have full scale")
	check(Road.project_point(2.0, 30.0).y > Road.project_point(2.0, 60.0).y
		and Road.project_scale(30.0) > Road.project_scale(60.0),
		"R03 approaching objects move down and enlarge")
	check(Road.project_point(1.0, 99999.0).is_equal_approx(Vector2(135, 178))
		and Road.project_point(1.0, -99999.0).is_finite(),
		"R04 edge case extreme depth stays finite and far depth clamps to horizon")
	print("ROAD TESTS: %d failure(s)" % failures)
	quit(0 if failures == 0 else 1)
