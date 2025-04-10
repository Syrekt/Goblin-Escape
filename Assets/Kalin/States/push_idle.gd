extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.movable.grab()
	#Make sure player is not stuck in object
	player.position.x -= player.facing

func physics_update(delta: float) -> void:
	player.movable.velocity = Vector2.ZERO


func update(delta: float) -> void:
	if player.just_pressed("grab"):
		finished.emit("idle");
		player.movable.release()
	var dir = Input.get_axis("left", "right")
	if dir == player.facing:
		finished.emit("push")
	elif dir == -player.facing:
		finished.emit("pull")
