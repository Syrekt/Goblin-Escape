extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "push_idle")
	player.movable.grab()
	#Make sure player is not stuck in object
	player.position.x -= player.facing

func physics_update(delta: float) -> void:
	player.movable.velocity = Vector2.ZERO


func update(delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		finished.emit("idle");
		player.movable.release()
	var dir = Input.get_axis("left", "right")
	Debugger.printui(["dir	: "+str(dir)]);
	if dir == player.facing:
		finished.emit("push")
	elif dir == -player.facing:
		finished.emit("pull")
