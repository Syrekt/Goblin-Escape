extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "run_stop")

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		finished.emit("fall")
