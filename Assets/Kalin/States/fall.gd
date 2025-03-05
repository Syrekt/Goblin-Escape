extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "fall")

func physics_update(delta: float) -> void:
	player.fall(delta)
	if player.is_on_floor():
		finished.emit("land")

	if !player.ignore_corners && player.ray_corner_check.is_colliding() && !player.ray_corner_prevent.is_colliding():
		finished.emit("corner_grab")

