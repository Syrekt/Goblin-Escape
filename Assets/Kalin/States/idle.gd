extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.animation_player.play("idle")
	lock_stance_button = true;

func update(_delta: float) -> void:
	if lock_stance_button:
		if not Input.is_action_pressed("stance"): lock_stance_button = false

	if not player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("down"):
		finished.emit("crouch")
	elif Input.is_action_pressed("up"):
		finished.emit("rise")
	elif not lock_stance_button and Input.is_action_just_pressed("stance") or Input.is_action_just_pressed("attack"):
		finished.emit("stance_light")
	elif player.get_movement_dir():
		if Input.is_action_pressed("run"):
			finished.emit("run")
		else:
			finished.emit("walk")
