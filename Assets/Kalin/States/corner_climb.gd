extends PlayerState


func enter(_previous_path_string: String, _data := {}) -> void:
	var camera = player.camera
	camera.position += Vector2(26*player.facing, -35)
	if player.state_node.last_state.name != "corner_grab":
		player.snap_to_corner(player.ray_corner_grab_check.get_collision_point())
	if player.corner_quick_climb:
		player.call_deferred("update_animation", "corner_climb_quick")
		player.corner_quick_climb = false
	else:
		player.call_deferred("update_animation", name)


func exit() -> void:
	var camera = player.camera
	player.global_position += Vector2(26*player.facing, -35)
	camera.position -= Vector2(26*player.facing, -35)
