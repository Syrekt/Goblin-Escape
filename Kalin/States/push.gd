extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.movable.grab()

func physics_update(delta: float) -> void:
	player.movable.velocity = player.velocity;

func update(delta: float) -> void:
	if player.movable.falling:
		finished.emit("idle")
		return

	player.stamina.spend(0.01, 0.1)
	if !player.stamina.has_enough(0.01):
		player.velocity.x = 0
		finished.emit("push_idle")

	#Drop the movable
	if !player.movable.grabbed:
		finished.emit("idle")

	if player.just_pressed("grab"):
		finished.emit("idle");
		player.movable.release()
	var dir = Input.get_axis("left", "right")
	if dir == -player.facing:
		finished.emit("pull")
	elif dir == 0:
		finished.emit("push_idle")
