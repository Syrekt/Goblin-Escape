extends PlayerAttackState

var charge_up := 0.0 # Used for slash

func enter(previous_state_path: String, data := {}) -> void:
	_enter()
	charge_up = data.get("charge_up", 0)
	player.fatigue.perform("slash")
func exit() -> void:
	_exit()

func update(delta: float) -> void:
	_update(delta)

func _on_attack_frame() -> void:
	var player_slash_damage = player.SLASH_DAMAGE + player.SLASH_DAMAGE_PER_STRENGTH * player.strength
	var damage_dealt = player_slash_damage * ((charge_up / 100) * 2)
	print("Slash damage: "+str(damage_dealt))
	print("Charge modifier: " + str(charge_up / 100))

	if hitbox.has_overlapping_bodies():
		for defender in hitbox.get_overlapping_bodies():
			print("defender: "+str(defender))
			if defender is Enemy:
				#Ge.slow_mo(0, 0.05)
				Ge.hit_stop(0.1)
				if !defender.chase_target:
					damage_dealt *= 2
				var defender_state = defender.state_node.state.name
				if defender_state == "stance_defensive":
					defender.combat_properties.stun(2.0)
					Ge.play_audio(player.audio_emitter, 1, "res://SFX/Kalin/block_break2.wav")
				else:
					defender.take_damage(damage_dealt, player, true)
					player.play_sfx(sfx_hit)
				defender.combat_properties.pushback_apply(player.global_position, pushback_force)
			else:
				defender.take_damage(damage_dealt, player)
	else:
		player.play_sfx(sfx_whiff)
