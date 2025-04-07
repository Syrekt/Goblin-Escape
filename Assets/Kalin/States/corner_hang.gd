extends PlayerState

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.global_position.x += 22
	player.global_position.y += 36
	player.set_facing(-player.facing)
