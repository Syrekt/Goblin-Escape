extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.set_facing(player.get_movement_dir())
	player.animation_player.call_deferred("play", "walk")
	player.animation_player.advance(0)
	lock_stance_button = true

func physics_update(delta: float) -> void:
	player.move(delta)
	player.check_movable();

func update(delta: float) -> void:
	if lock_stance_button:
		if not Input.is_action_pressed("stance"): lock_stance_button = false

	if !player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("run"):
		finished.emit("run")
	elif Input.is_action_pressed("down"):
		finished.emit("crouch")
	elif Input.is_action_just_pressed("up"):
		finished.emit("rise")
	elif not lock_stance_button and Input.is_action_just_pressed("stance") or Input.is_action_just_pressed("attack"):
		finished.emit("stance_walk")
	elif is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("idle")
