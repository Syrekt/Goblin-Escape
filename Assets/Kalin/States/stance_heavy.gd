extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "stance_heavy")

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("stance"):
		finished.emit("idle")
	elif not Input.is_action_pressed("up"):
		finished.emit("stance_light")
	elif Input.is_action_pressed("down"):
		finished.emit("stance_defensive")
	elif Input.is_action_pressed("attack"):
		finished.emit("slash")
	elif not is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("stance_walk")
