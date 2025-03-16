extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = -player.jump_impulse
	if player.can_grab_corner() && player.ray_auto_climb.is_colliding():
		player.quick_climb()
	else:
		player.call_deferred("update_animation", name)

func update(delta):
	var can_quick_climb = player.velocity.y < -50.0
	if player.can_grab_corner():
		if can_quick_climb && player.ray_auto_climb.is_colliding():
			player.quick_climb()
		if player.ray_corner_grab_check.is_colliding():
			if player.col_auto_climb_bottom.has_overlapping_bodies():
				player.quick_climb()
			elif Input.is_action_pressed("up"):
				finished.emit("corner_climb")
			else:
				finished.emit("corner_grab")

	if player.velocity.y >= 0 && player.is_on_floor():
		finished.emit("idle")
	elif player.velocity.y >= 0:
		finished.emit("fall")
