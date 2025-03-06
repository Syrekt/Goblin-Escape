extends PlayerState

var input_direction_x := 0

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "crouch")
	player.set_crouch_mask(true)
	player.velocity = Vector2.ZERO

func physics_update(delta: float) -> void:
	Debugger.printui("player.can_stand_up(): "+str(player.can_stand_up()));
	player.move_and_slide()
	if not player.is_on_floor():
		finished.emit("fall")
		player.set_crouch_mask(false)
	elif !Input.is_action_pressed("down") && player.can_stand_up():
		finished.emit("idle")
		player.set_crouch_mask(false)
	elif Input.is_action_just_pressed("up"):
		print("drop from platform")
	elif not is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("crouch_walk")
