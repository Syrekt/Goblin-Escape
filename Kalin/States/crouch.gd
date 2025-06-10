extends PlayerState

var input_direction_x := 0


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity = Vector2.ZERO
	player.ray_light.position.y = 14

func exit() -> void:
	player.ray_light.position.y = 0

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		finished.emit("fall")
	elif !player.pressed("down") && player.can_stand_up():
		finished.emit("idle")
	elif player.just_pressed("jump"):
		for i in player.get_slide_collision_count():
			var collider = player.cell_check.get_collider()
			print("collider: "+str(collider))
			if collider is TileMapLayer:
				var cell = collider.local_to_map(player.cell_check.get_collision_point())
				var data = collider.get_cell_tile_data(cell)
				if data.is_collision_polygon_one_way(0, 0):
					player.global_position.y += 4
			elif collider.is_in_group("OneWayColliders"):
				player.global_position.y += 4
	elif !is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("crouch_walk")
	elif !player.col_corner_hang.has_overlapping_bodies():
		finished.emit("corner_hang")
