extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	var pos = player.global_position
	pos.x += player.facing * 12
	player.combat_properties.pushback_apply(pos, 80)
