extends PlayerAttackState

@onready var stab_sfx : FmodEventEmitter2D = $StabSFX


func enter(previous_state_path: String, data := {}) -> void:
	_enter()
	player.fatigue.perform("stab")
func exit() -> void:
	_exit()

func update(delta: float) -> void:
	_update(delta)

func _on_attack_frame() -> void:
	if hitbox.has_overlapping_bodies():
		var player_stab_damage = player.STAB_DAMAGE + player.STAB_DAMAGE_PER_STRENGTH * player.strength

		#Allow buffering next attack on hit
		can_buffer_next_attack = true
		var defender = hitbox.get_overlapping_bodies()[0]
		if defender is Enemy:
			var defender_state = defender.state_node.state.name
			if defender_state == "stance_defensive" || defender_state == "bash":
				player.combat_properties.stun(2.0)
				stab_sfx.set_parameter("AttackResult", "Blocked")
				Talo.events.track("Player stunned while stabbing defending enemy")
			else:
				defender.combat_properties.pushback_apply(player.global_position, pushback_force)
				defender.take_damage(player_stab_damage, player)
				stab_sfx.set_parameter("AttackResult", "HitOrganic")
				Ge.slow_mo(0, 0.05)
		else:
			defender.take_damage(0, player)
			if !player.has_heavy_stance:
				player.think("I can't break it yet")
			else:
				player.think("I should hit harder")
	else:
		stab_sfx.set_parameter("AttackResult", "Miss")
	stab_sfx.play()
