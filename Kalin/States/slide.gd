extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = player.slide_speed * player.facing
	player.set_crouch_mask(true)
	player.ray_light.position.y = 14

func exit() -> void:
	player.ray_light.position.y = 0

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		finished.emit("fall")
