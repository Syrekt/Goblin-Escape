extends PlayerState


func enter(_previous_path_string: String, _data := {}) -> void:
	if player.corner_quick_climb:
		player.call_deferred("update_animation", "corner_climb_quick")
		player.corner_quick_climb = false
	else:
		player.call_deferred("update_animation", name)


