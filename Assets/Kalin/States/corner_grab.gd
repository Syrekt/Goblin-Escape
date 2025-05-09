extends PlayerState

var just_entered := false

func enter(previous_path_string: String, data := {}) -> void:
	if previous_path_string != "corner_hang":
		player.snap_to_corner(player.ray_corner_grab_check.get_collision_point())
	player.call_deferred("update_animation", name)

func exit() -> void:
	if player.pcam:
		player.pcam.follow_offset = Vector2.ZERO

func update(delta: float) -> void:
	if player.pressed("up"):
		finished.emit("corner_climb")
	if player.just_pressed("down"):
		player.ignore_corners = true;
		finished.emit("fall")
