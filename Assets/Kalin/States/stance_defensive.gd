extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		finished.emit("fall")
	elif player.pressed("stance"):
		finished.emit("idle")
	elif player.pressed("up"):
		finished.emit("stance_heavy")
	elif !player.pressed("down"):
		finished.emit("stance_light")
	elif player.pressed("attack") && player.stamina.spend(player.BASH_COST):
		finished.emit("bash")
	elif not is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("stance_walk")
