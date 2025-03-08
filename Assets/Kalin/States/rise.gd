extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.direction_locked = true
	player.velocity.y = -player.jump_impulse
	player.call_deferred("update_animation", "rise")

func update(delta):
	if player.velocity.y >= 0 && player.is_on_floor():
		player.direction_locked = false
		finished.emit("idle")
	if player.velocity.y >= 0:
		finished.emit("fall")
