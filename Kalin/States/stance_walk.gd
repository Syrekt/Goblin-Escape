extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	if player.get_movement_dir() == -player.facing:
		player.call_deferred("update_animation", name, -1)
	else:
		player.call_deferred("update_animation", name)
	player.velocity.x = 0;

	lock_stance_button = true;

func update(delta):
	if lock_stance_button:
		if !player.pressed("stance"): lock_stance_button = false


	if! player.is_on_floor():
		finished.emit("fall")
	elif !lock_stance_button && player.just_pressed("stance"):
		finished.emit("walk")
	elif player.pressed("sprint"):
		finished.emit("run")
	elif player.pressed("attack") && player.stamina.spend(player.STAB_STAMINA_COST, 1.0):
		finished.emit("stab")
	elif player.get_movement_dir() == 0:
		finished.emit("stance_light")
