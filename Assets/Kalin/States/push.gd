extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "push")
	player.movable.grab()


func physics_update(delta: float) -> void:
	player.facing_locked = true
	player.movable.velocity.x = player.velocity.x;

func update(delta: float) -> void:
	#Drop the movable
	if !player.movable.grabbed:
		finished.emit("idle")
		player.facing_locked = false

	if Input.is_action_just_pressed("grab"):
		finished.emit("idle");
		player.movable.release()
		player.facing_locked = false
	var dir = Input.get_axis("left", "right")
	if dir == -player.facing:
		finished.emit("pull")
	elif dir == 0:
		finished.emit("push_idle")
	pass
