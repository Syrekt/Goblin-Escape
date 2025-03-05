extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "pull")
	player.movable.grab()

func physics_update(delta: float) -> void:
	player.move(delta);
	player.movable.velocity = player.velocity;

func update(delta: float) -> void:
	if(Input.is_action_just_pressed("grab")):
		finished.emit("idle");
		player.movable.release()
	var dir = Input.get_axis("left", "right")
	if(dir == player.facing):
		finished.emit("push")
	elif(dir == 0):
		finished.emit("push_idle")
