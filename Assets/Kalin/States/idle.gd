extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.call_deferred("update_animation", "idle")
	lock_stance_button = true;

func update(_delta: float) -> void:
	player.check_movable();
	if lock_stance_button:
		if not Input.is_action_pressed("stance"): lock_stance_button = false

	if !player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("down"):
		finished.emit("crouch")
	elif Input.is_action_pressed("up"):
		finished.emit("rise")
	elif !lock_stance_button && Input.is_action_just_pressed("stance") || Input.is_action_just_pressed("attack"):
		finished.emit("stance_light")
	elif player.velocity.x != 0:
		if Input.is_action_pressed("run"):
			finished.emit("run")
		else:
			finished.emit("walk")
