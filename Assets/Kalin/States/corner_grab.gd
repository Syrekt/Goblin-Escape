extends PlayerState

func enter(previous_path_string: String, data := {}) -> void:
	player.position.x += player.facing*10
	player.animation_player.call_deferred("play", "corner_grab")

func update(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		finished.emit("corner_climb")
	if Input.is_action_just_pressed("down"):
		player.ignore_corners = true;
		finished.emit("fall")
