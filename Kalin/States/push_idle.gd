extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.movable.grab()
	print("player.is_on_wall(): "+str(player.is_on_wall()));
	if player.is_on_wall():
		#Make sure player is not stuck in object
		player.position.x -= player.facing

func update(delta: float) -> void:
	if player.just_pressed("grab"):
		finished.emit("idle");
		player.movable.release()

	var dir = Input.get_axis("left", "right")
	# Stop if movable is on wall
	if dir == player.facing && !player.movable.is_on_wall():
		if player.stamina.has_enough(0.1):
			finished.emit("push")
	elif dir == -player.facing:
		if player.stamina.has_enough(0.1):
			finished.emit("pull")
