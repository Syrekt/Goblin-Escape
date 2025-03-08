extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "push_idle")
	player.movable.grab()
	#Make sure player is not stuck in object
	player.position.x -= player.facing
	player.facing_locked = true

func physics_update(delta: float) -> void:
	player.movable.velocity = Vector2.ZERO


func update(delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		player.facing_locked = true
		finished.emit("idle");
		player.movable.release()
	var dir = Input.get_axis("left", "right")
	Debugger.printui("dir	: "+str(dir));
	if dir == player.facing:
		finished.emit("push")
	elif dir == -player.facing:
		finished.emit("pull")
