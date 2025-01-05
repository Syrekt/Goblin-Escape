extends PlayerState

var input_direction_x := 0

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("crouch_walk")
	player.set_crouch_mask(true)

func physics_update(delta: float) -> void:
	player.move(delta)

	if not player.is_on_floor():
		finished.emit("fall")
		player.set_crouch_mask(false)
	elif not Input.is_action_pressed("down"):
		finished.emit("idle")
		player.set_crouch_mask(false)
	elif Input.is_action_just_pressed("up"):
		print("drop down the platform")
		#finished.emit("rise")
	elif is_equal_approx(player.get_movement_dir(), 0.0):
		if Input.is_action_pressed("down"):
			finished.emit("crouch")
		else:
			finished.emit("idle")
			player.set_crouch_mask(false)
