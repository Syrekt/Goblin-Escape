extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("land")
