extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.set_floor_snap_length(2.0)
	player.set_facing(player.get_movement_dir())

func update(delta: float) -> void:
	if player.combat_target && !%Stamina.spend(0.01):
		finished.emit("run_stop")

func physics_update(delta: float) -> void:
	player.check_movable();
	var floor_angle = player.get_floor_angle()

	if !player.pressed("run") || player.get_movement_dir() != player.facing || player.velocity.x == 0:
		finished.emit("run_stop")
	elif player.pressed("down") && floor_angle == 0:
		finished.emit("slide")
	elif !player.is_on_floor():
		finished.emit("fall")
	elif player.just_pressed("jump"):
		player.velocity.x = 10.0 * player.facing
		finished.emit("rise")
	elif is_equal_approx(Input.get_axis("left", "right"), 0.0):
		finished.emit("idle")

func play_footsteps() -> void:
	Ge.play_audio_from_string_array(%AnimationAudioStreamer, 1, "res://Assets/SFX/Kalin/Footsteps Soft/")
