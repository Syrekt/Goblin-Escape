extends PlayerState



func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.set_facing(player.get_movement_dir())
func exit() -> void:
	player.sprinting = false
	player.animation_player.speed_scale = 1.0
	player.set_floor_snap_length(12.0)

func update(delta: float) -> void:
	player.sprinting = player.pressed("sprint") && player.stamina.has_enough(0.1)
	if player.sprinting:
		player.stamina.spend(0.01, 0.001)
		player.animation_player.speed_scale = 1.25
		player.set_floor_snap_length(3.0)
	else:
		player.animation_player.speed_scale = 1.0
		player.set_floor_snap_length(2.0)


func physics_update(delta: float) -> void:
	player.check_movable();
	var floor_angle = player.get_floor_angle()

	if player.pressed("walk") || (!player.pressed("left") && !player.pressed("right")):
		finished.emit("run_stop")
	elif player.pressed("down") && floor_angle == 0:
		print("elapsed_time: "+str(elapsed_time))
		if elapsed_time >= 0.5:
			finished.emit("slide", {"sprinting": player.sprinting})
		else:
			finished.emit("crouch")
	elif !player.is_on_floor():
		finished.emit("fall")
	elif player.just_pressed("jump"):
		finished.emit("rise")
	elif is_equal_approx(Input.get_axis("left", "right"), 0.0):
		finished.emit("idle")
	elif !player.has_sword && player.just_pressed("attack") && player.stamina.spend(1.0):
		finished.emit("bash_no_sword")

func play_footsteps() -> void:
	if player.sprinting:
		Ge.play_audio_from_string_array(player.global_position, 1, "res://SFX/Kalin/Footsteps Soft/")
