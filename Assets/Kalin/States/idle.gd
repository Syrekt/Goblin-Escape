extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.call_deferred("update_animation", name)
	lock_stance_button = true;

func update(_delta: float) -> void:
	player.check_movable();
	if lock_stance_button:
		if not player.pressed("stance"): lock_stance_button = false

	if !player.is_on_floor():
		finished.emit("fall")
	elif player.pressed("down"):
		finished.emit("crouch")
	elif player.just_pressed("jump"):
		finished.emit("rise")
	elif player.has_sword && !lock_stance_button && (player.just_pressed("stance") || player.just_pressed("attack")):
		finished.emit("stance_light")
	elif player.velocity.x != 0:
		if player.pressed("run") && %Stamina.has_enough(1.0):
			finished.emit("run")
		else:
			finished.emit("walk")
