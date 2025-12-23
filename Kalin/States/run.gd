extends PlayerState


@onready var footstep_emitter : FmodEventEmitter2D = $Footsteps


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
		player.fatigue.add(0.001)
		player.animation_player.speed_scale = 1.25
		player.set_floor_snap_length(3.0)
	else:
		player.animation_player.speed_scale = 1.0
		player.set_floor_snap_length(2.0)
		player.fatigue.add(0.0001)


func physics_update(delta: float) -> void:
	player.check_movable();
	var floor_angle = player.get_floor_angle()

	if player.sprinting && (player.pressed("walk") || (!player.pressed("left") && !player.pressed("right"))):
		finished.emit("run_stop")
	elif player.pressed("walk"):
		finished.emit("walk")
	elif player.has_sword && player.just_pressed("stance"):
		finished.emit("stance_walk")
	elif player.pressed("down"):
		if elapsed_time >= 0.5 && floor_angle == 0:
			finished.emit("slide", {"sprinting": player.sprinting})
		else:
			finished.emit("crouch")
	elif !player.is_on_floor():
		finished.emit("fall")
	elif player.just_pressed("jump"):
		finished.emit("rise")
	#elif is_equal_approx(Input.get_axis("left", "right"), 0.0):
	elif player.get_movement_dir() == 0:
		finished.emit("idle")
	elif player.just_pressed("attack") && player.stamina.spend(player.bash_cost):
		finished.emit("bash_no_sword")

func play_footsteps() -> void:
	if !player.status_effect_container.has_status_effect("Feather Step"):
		if player.sprinting:
			footstep_emitter.set_parameter("Type", "Sprinting")
		else:
			footstep_emitter.set_parameter("Type", "Running")
		footstep_emitter.play()

