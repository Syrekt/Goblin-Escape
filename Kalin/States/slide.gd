extends PlayerState

var was_sprinting := false


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.ray_light.position.y = 14

	was_sprinting = data.get("sprinting", false)
	if was_sprinting:
		player.velocity.x = player.sprint_slide_speed * player.facing
	else:
		player.velocity.x = player.slide_speed * player.facing

func exit() -> void:
	player.ray_light.position.y = 0

func physics_update(delta: float) -> void:
	var floor_angle = player.get_floor_angle()

	if !player.is_on_floor():
		finished.emit("fall")
	elif floor_angle == 0 && !player.col_corner_hang.has_overlapping_bodies():
		finished.emit("corner_hang")
