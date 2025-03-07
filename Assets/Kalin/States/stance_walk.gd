extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.set_facing(player.get_movement_dir())
	player.animation_player.call_deferred("play", "stance_walk")
	lock_stance_button = true;

func update(delta):
	if lock_stance_button:
		if not Input.is_action_pressed("stance"): lock_stance_button = false

	if not player.is_on_floor():
		finished.emit("fall")
	elif not lock_stance_button and Input.is_action_just_pressed("stance"):
		finished.emit("walk")
	elif Input.is_action_pressed("run"):
		finished.emit("run")
	elif Input.is_action_pressed("attack"):
		finished.emit("stab")
	elif player.get_movement_dir() == 0:
		finished.emit("stance_light")
