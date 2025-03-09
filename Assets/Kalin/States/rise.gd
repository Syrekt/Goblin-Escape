extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = -player.jump_impulse
	player.call_deferred("update_animation", "rise")

func update(delta):
	Debugger.printui("velocity.y: "+str(player.velocity.y));
	var can_quick_climb = player.velocity.y < -50.0
	if player.can_grab_corner():
		if can_quick_climb && player.ray_auto_climb.is_colliding():
			player.corner_quick_climb = true
			finished.emit("corner_climb")
		if player.ray_corner_grab_check.is_colliding():
			if Input.is_action_pressed("up"):
				finished.emit("corner_climb")
			else:
				finished.emit("corner_grab")

	if player.velocity.y >= 0 && player.is_on_floor():
		finished.emit("idle")
	if player.velocity.y >= 0:
		finished.emit("fall")
