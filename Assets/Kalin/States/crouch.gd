extends PlayerState

var input_direction_x := 0

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "crouch")
	player.set_crouch_mask(true)

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		finished.emit("fall")
		player.set_crouch_mask(false)
	elif not Input.is_action_pressed("down"):
		finished.emit("idle")
		player.set_crouch_mask(false)
	elif Input.is_action_just_pressed("up"):
		print("drop from platform")
	elif not is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("crouch_walk")
