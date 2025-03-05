extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "run_stop")

func exit():
	player.set_facing(player.get_movement_dir())


func update(delta):
	pass

func physics_update(delta: float) -> void:
	player.move(delta)

	if not player.is_on_floor():
		finished.emit("fall")
