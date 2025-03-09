extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "run")
	player.set_floor_snap_length(2.0)
	player.set_facing(player.get_movement_dir())

func physics_update(delta: float) -> void:
	player.check_movable();
	var floor_angle = player.get_floor_angle()

	if !Input.is_action_pressed("run") || player.get_movement_dir() != player.facing || player.velocity.x == 0:
		finished.emit("run_stop")
	elif Input.is_action_pressed("down") && floor_angle == 0:
		finished.emit("slide")
	elif !player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_just_pressed("up"):
		player.velocity.x = 10.0 * player.facing
		finished.emit("rise")
	elif is_equal_approx(Input.get_axis("left", "right"), 0.0):
		finished.emit("idle")
