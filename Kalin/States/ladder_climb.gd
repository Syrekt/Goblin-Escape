extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass
func update(delta: float) -> void:
	if !player.ladder:
		finished.emit("idle")
	if Input.is_action_pressed("up"):
		player.velocity.y = -3000.0 * delta
	elif Input.is_action_pressed("down"):
		player.velocity.y = 3000.0 * delta
		if player.is_on_floor():
			finished.emit("idle")
	elif Input.is_action_pressed("left") || Input.is_action_pressed("right"):
		finished.emit("idle")
	else:
		player.velocity.y = 0
