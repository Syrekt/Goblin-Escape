extends PlayerState

var input_direction_x := 0


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.set_crouch_mask(true)
	player.velocity = Vector2.ZERO
	player.ray_light.position.y = 14

func exit() -> void:
	player.ray_light.position.y = 0

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		finished.emit("fall")
		player.set_crouch_mask(false)
	elif !player.pressed("down") && player.can_stand_up():
		player.stand_up()
	elif player.just_pressed("jump"):
		if player.get_slide_collision_count() > 0:
			var collider = player.get_slide_collision(0).get_collider()
			print("collider: "+str(collider))
			if collider.has_node("Shape"):
				var shape = collider.get_node("Shape")
				if shape.one_way_collision:
					player.global_position.y += 4
	elif !is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("crouch_walk")
	elif !player.col_corner_hang.has_overlapping_bodies():
		finished.emit("corner_hang")
