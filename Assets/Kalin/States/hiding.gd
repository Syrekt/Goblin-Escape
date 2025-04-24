extends PlayerState

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.invisible = true

func exit() -> void:
	player.invisible = false

func update(delta : float) -> void:
	if player.get_movement_dir() != 0 || Input.is_action_just_pressed("interact"):
		finished.emit("unhide")
