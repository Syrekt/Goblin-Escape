extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	if player.get_movement_dir() == -player.facing:
		player.call_deferred("update_animation", "stance_walk", -1)
	else:
		player.call_deferred("update_animation", "stance_walk")
	player.velocity.x = 0;

	lock_stance_button = true;

func update(delta):
	if lock_stance_button:
		if !Input.is_action_pressed("stance"): lock_stance_button = false

	if! player.is_on_floor():
		finished.emit("fall")
	elif !lock_stance_button && Input.is_action_just_pressed("stance"):
		finished.emit("walk")
	elif Input.is_action_pressed("run"):
		finished.emit("run")
	elif Input.is_action_pressed("attack"):
		finished.emit("stab")
	elif player.get_movement_dir() == 0:
		finished.emit("stance_light")
