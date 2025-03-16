extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = -player.jump_impulse
	if player.can_grab_corner() && player.ray_auto_climb.is_colliding():
		player.quick_climb()
	else:
		player.call_deferred("update_animation", name)

func update(delta):
	if player.can_grab_corner():
		if player.ray_corner_grab_check.is_colliding():
			if player.col_auto_climb_bottom.has_overlapping_bodies():
				player.quick_climb()
			else:
				finished.emit("corner_grab")
		elif player.can_quick_climb():
			var collider = player.ray_auto_climb.get_collider()
			print("collider: "+str(collider))
			player.quick_climb()

	if player.velocity.y >= 0 && player.is_on_floor():
		finished.emit("idle")
	elif player.velocity.y >= 0:
		finished.emit("fall")
