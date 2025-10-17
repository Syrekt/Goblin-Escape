extends PlayerState

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.global_position += Vector2(22 * player.facing, 36)
	player.pcam.follow_offset = Vector2(-22, -36)
	player.set_facing(-player.facing)

	var tween_pcam = create_tween().bind_node(self).set_ease(Tween.EASE_OUT)
	if player.pcam:
		tween_pcam.tween_property(player.pcam, "follow_offset", Vector2(0, 0), 1.4)
