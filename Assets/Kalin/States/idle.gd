extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * _delta
	player.move_and_slide()

	if not player.is_on_floor():
		print("fall")
		finished.emit("falling")
	elif Input.is_action_just_pressed("jump"):
		finished.emit("jumping")
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit("running")
