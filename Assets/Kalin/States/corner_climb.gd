extends PlayerState

func enter(_previous_path_string: String, _data := {}) -> void:
	player.animation_player.call_deferred("play", "corner_climb")
