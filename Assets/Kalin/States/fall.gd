extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("fall")

func physics_update(delta: float) -> void:
	player.fall(delta)

	if player.is_on_floor():
		finished.emit("land")
