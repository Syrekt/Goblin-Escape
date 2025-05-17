extends PlayerAttackState

var charge_up := 0.0 # Used for slash

func enter(previous_state_path: String, data := {}) -> void:
	_enter()
	charge_up = data.get("charge_up", 0)

func update(delta: float) -> void:
	_update(delta)

func _on_attack_frame() -> void:
	print("On attack frame")
	var damage = player.slash_damage * 2 if charge_up == 100 else player.slash_damage
	if hitbox.has_overlapping_bodies():
		for defender in hitbox.get_overlapping_bodies():
			if defender is Enemy:
				var defender_state = defender.state_node.state.name
				if defender_state == "stance_defensive":
					defender.combat_properties.stun(2.0)
					Ge.play_audio(player.audio_emitter, 1, "res://Assets/SFX/Kalin/block_break2.wav")
				else:
					defender.take_damage(damage, player)
					player.play_sfx(sfx_hit)
				defender.combat_properties.pushback_apply(player.global_position, pushback_force)
			else:
				defender.take_damage(damage, player)
	else:
		player.play_sfx(sfx_whiff)
