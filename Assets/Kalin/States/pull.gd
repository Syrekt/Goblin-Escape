extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "pull")
	player.movable.grab()

func physics_update(delta: float) -> void:
	player.facing_locked = true
	player.movable.velocity = player.velocity;

func update(delta: float) -> void:
	#Drop the movable
	if !player.movable.grabbed:
		player.facing_locked = false
		finished.emit("idle")

	if Input.is_action_just_pressed("grab"):
		player.facing_locked = false
		finished.emit("idle");
		player.movable.release()
	var dir = Input.get_axis("left", "right")
	if dir == player.facing:
		finished.emit("push")
	elif dir == 0:
		finished.emit("push_idle")
