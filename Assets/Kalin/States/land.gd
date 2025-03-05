extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "land")
	player.ignore_corners = false
