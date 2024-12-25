extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("walk")
	lock_stance_button = true

func physics_update(delta: float) -> void:
	player.move(delta)

func update(delta: float) -> void:
	if lock_stance_button:
		if not Input.is_action_pressed("stance"): lock_stance_button = false

	if not player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("run"):
		finished.emit("run")
	elif Input.is_action_pressed("down"):
		finished.emit("crouch")
	elif Input.is_action_just_pressed("up"):
		finished.emit("rise")
	elif not lock_stance_button and Input.is_action_just_pressed("stance"):
		finished.emit("stance_walk")
	elif is_equal_approx(Input.get_axis("left", "right"), 0.0):
		finished.emit("idle")
