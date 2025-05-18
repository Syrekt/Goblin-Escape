extends PlayerAttackState

func enter(previous_state_path: String, data := {}) -> void:
	_enter()

func update(delta: float) -> void:
	_update(delta)

func _on_attack_frame() -> void:
	if hitbox.has_overlapping_bodies():
		#Allow buffering next attack on hit
		can_buffer_next_attack = true
		var defender = hitbox.get_overlapping_bodies()[0]
		if defender is Enemy:
			var defender_state = defender.state_node.state.name
			if defender_state == "stance_defensive":
				player.combat_properties.stun(2.0)
				Ge.play_audio_from_string_array(player.audio_emitter, 0, "res://SFX/Sword hit shield")
			else:
				defender.combat_properties.pushback_apply(player.global_position, pushback_force)
				defender.take_damage(player.stab_damage, player)
				player.play_sfx(sfx_hit)
		else:
			defender.take_damage(0, player)
			player.think("I should hit harder")
	else:
		player.play_sfx(sfx_whiff)
