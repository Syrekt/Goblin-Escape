extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = 0
	lock_stance_button = true;


func update(delta: float) -> void:
	if lock_stance_button:
		if !Input.is_action_pressed("stance"): lock_stance_button = false

	if !player.is_on_floor():
		finished.emit("fall")
	elif !lock_stance_button && Input.is_action_just_pressed("stance"):
		finished.emit("idle")
	elif Input.is_action_pressed("up"):
		finished.emit("stance_heavy")
	elif Input.is_action_pressed("down"):
		finished.emit("stance_defensive")
	elif Input.is_action_pressed("attack") && player.stamina.spend(player.STAB_COST):
		finished.emit("stab")
	elif !is_equal_approx(player.get_movement_dir(), 0.0):
		if Input.is_action_pressed("run") && %Stamina.has_enough(1.0):
			finished.emit("run")
		else:
			finished.emit("stance_walk")
