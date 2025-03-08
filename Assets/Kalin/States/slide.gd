extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "slide")
	player.velocity.x = player.slide_speed * player.facing
	player.set_crouch_mask(true)

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		finished.emit("fall")
