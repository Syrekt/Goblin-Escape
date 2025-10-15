extends PlayerState


func enter(_previous_path_string: String, _data := {}) -> void:
	player.climb_start_position = player.global_position
	var tween_player = create_tween().bind_node(self).set_ease(Tween.EASE_OUT)
	var tween_sprite = create_tween().bind_node(self).set_ease(Tween.EASE_OUT)

	var target_position = player.global_position + Vector2(26*player.facing, -35)


	if player.corner_quick_climb:
		player.call_deferred("update_animation", "corner_climb_quick")
		player.corner_quick_climb = false
		tween_player.tween_property(player, "global_position", target_position, 0.6)
		tween_sprite.tween_property(player.sprite, "offset", Vector2(26*-player.facing, 35), 0.6)
	else:
		player.call_deferred("update_animation", name)
		tween_player.tween_property(player, "global_position", target_position, 1.4)
		tween_sprite.tween_property(player.sprite, "offset", Vector2(26*-player.facing, 35), 1.4)

func exit() -> void:
	player.sprite.offset = Vector2.ZERO
	player.climb_start_position = Vector2.ZERO
