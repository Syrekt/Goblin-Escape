extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "run")

func physics_update(delta: float) -> void:
	player.move(delta)
	player.check_movable();

	if not Input.is_action_pressed("run") or player.get_movement_dir() != player.facing:
		finished.emit("run_stop")
	elif Input.is_action_pressed("down"):
		finished.emit("crouch")
	elif not player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_just_pressed("up"):
		finished.emit("rise")
	elif is_equal_approx(Input.get_axis("left", "right"), 0.0):
		finished.emit("idle")
