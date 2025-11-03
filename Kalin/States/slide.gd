extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = player.slide_speed * player.facing
	player.ray_light.position.y = 14

func exit() -> void:
	player.ray_light.position.y = 0

func physics_update(delta: float) -> void:
	var floor_angle = player.get_floor_angle()

	if !player.is_on_floor():
		finished.emit("fall")
	elif floor_angle == 0 && !player.col_corner_hang.has_overlapping_bodies():
		finished.emit("corner_hang")
