extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("run_stop")

func physics_update(delta: float) -> void:
	player.move(delta)

	if not player.is_on_floor():
		finished.emit("fall")
