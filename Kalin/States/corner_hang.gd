extends PlayerState

func enter(previous_state_path : String, data := {}) -> void:
	if previous_state_path == "crouch_walk" || previous_state_path == "crouch":
		player.call_deferred("update_animation", "crouch_corner_hang")
	elif previous_state_path == "slide":
		player.call_deferred("update_animation", "corner_hang_quick")
	else:
		player.call_deferred("update_animation", name)
	player.global_position += Vector2(22 * player.facing, 36)
	if player.pcam:
		player.pcam.follow_offset = Vector2(-22, -36)
	player.set_facing(-player.facing)

	var tween_pcam = create_tween().bind_node(self).set_ease(Tween.EASE_OUT)
	if player.pcam:
		tween_pcam.tween_property(player.pcam, "follow_offset", Vector2(0, 0), 1.4)
