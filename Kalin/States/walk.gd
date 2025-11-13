extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	lock_stance_button = true



func update(delta: float) -> void:
	if lock_stance_button:
		if !player.pressed("stance"): lock_stance_button = false

	if !player.is_on_floor():
		finished.emit("fall")
	elif !player.pressed("walk"):
		finished.emit("run")
	elif player.pressed("down"):
		finished.emit("crouch")
	elif player.just_pressed("jump"):
		finished.emit("rise")
	elif player.just_pressed("attack") && player.stamina.spend(1.0):
		finished.emit("bash_no_sword")
	elif player.has_sword && !lock_stance_button && player.just_pressed("stance"):
		finished.emit("stance_walk")
	elif player.get_movement_dir() == 0:
		finished.emit("idle")

func physics_update(delta: float) -> void:
	player.check_movable();

func play_footsteps() -> void:
	Ge.play_audio_from_string_array(player.global_position, -10, "res://SFX/Kalin/Footsteps Soft/")
