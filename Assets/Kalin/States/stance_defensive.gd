extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "stance_defensive")

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("stance"):
		finished.emit("idle")
	elif Input.is_action_pressed("up"):
		finished.emit("stance_heavy")
	elif not Input.is_action_pressed("down"):
		finished.emit("stance_light")
	elif Input.is_action_pressed("attack") && player.stamina.spend(player.BASH_COST):
		finished.emit("bash")
	elif not is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("stance_walk")
