extends PlayerState

var z_index_prv : int

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.hiding = true
	player.set_collision_layer_value(2, false)
	player.set_collision_mask_value(4, false)
	z_index_prv = player.z_index
	player.z_index = player.hiding_spot.z_index + 1

func exit() -> void:
	player.hiding = false
	player.z_index = z_index_prv
	player.set_collision_layer_value(2, true)
	player.set_collision_mask_value(4, true)

func update(delta : float) -> void:
	if player.get_movement_dir() != 0 || Input.is_action_just_pressed("interact"):
		finished.emit("unhide")

