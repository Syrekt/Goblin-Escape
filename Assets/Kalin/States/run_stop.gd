extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "run_stop")
	player.facing_locked = true

func exit():
	player.facing_locked = false


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		finished.emit("fall")
