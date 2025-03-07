extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.direction_locked = true
	player.animation_player.call_deferred("play", "land")
	player.ignore_corners = false

func exit() -> void:
	player.direction_locked = false
