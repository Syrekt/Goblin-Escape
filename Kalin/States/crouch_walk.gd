extends PlayerState

var input_direction_x := 0

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.ray_light.position.y = 14

func exit() -> void:
	player.ray_light.position.y = 0

func physics_update(delta: float) -> void:
	var floor_angle = player.get_floor_angle()
	if not player.is_on_floor():
		finished.emit("fall")
	elif !player.pressed("down") && player.can_stand_up():
		finished.emit("idle")
	elif player.pressed("attack") && floor_angle == 0:
		finished.emit("slide")
	elif is_equal_approx(player.get_movement_dir(), 0.0):
		if player.pressed("down") || !player.can_stand_up():
			finished.emit("crouch")
		else:
			finished.emit("idle")
	elif player.just_pressed("jump"):
		if player.is_on_one_way_collider:
			player.global_position.y += 4
		else:
			player.ignore_platforms()
	elif floor_angle == 0 && !player.col_corner_hang.has_overlapping_bodies():
		finished.emit("corner_hang")
