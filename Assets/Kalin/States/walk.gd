extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	lock_stance_button = true



func update(delta: float) -> void:
	if lock_stance_button:
		if !Input.is_action_pressed("stance"): lock_stance_button = false

	if !player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("run") && %Stamina.has_enough(1.0):
		finished.emit("run")
	elif Input.is_action_pressed("down"):
		finished.emit("crouch")
	elif Input.is_action_just_pressed("up"):
		finished.emit("rise")
	elif not lock_stance_button and Input.is_action_just_pressed("stance") or Input.is_action_just_pressed("attack"):
		finished.emit("stance_walk")
	elif player.velocity.x == 0:
		finished.emit("idle")

func physics_update(delta: float) -> void:
	player.check_movable();

func play_footsteps() -> void:
	Ge.play_audio_from_string_array(%AnimationAudioStreamer, -10, "res://Assets/SFX/Kalin/Footsteps Soft/")
