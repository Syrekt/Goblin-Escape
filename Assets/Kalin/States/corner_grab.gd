extends PlayerState

var just_entered := false

func enter(previous_path_string: String, data := {}) -> void:
	print("previous_path_string: "+str(previous_path_string))
	player.snap_to_corner(player.ray_corner_grab_check.get_collision_point())
	player.call_deferred("update_animation", name)

func update(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		finished.emit("corner_climb")
	if Input.is_action_just_pressed("down"):
		player.ignore_corners = true;
		finished.emit("fall")
