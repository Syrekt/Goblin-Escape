extends PlayerState

func enter(_previous_path_string: String, _data := {}) -> void:
	player.call_deferred("update_animation", "corner_climb")
