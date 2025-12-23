extends PlayerAttackState

var charge_up := 0.0 # Used for slash

@onready var slash_emitter : FmodEventEmitter2D = $SlashSFX

func enter(previous_state_path: String, data := {}) -> void:
	_enter()
	charge_up = data.get("charge_up", 0)
	player.fatigue.perform("slash")
	print("player.slash_cost: "+str(player.slash_cost));
func exit() -> void:
	_exit()

func update(delta: float) -> void:
	_update(delta)

func _on_attack_frame() -> void:
	var player_slash_damage = player.SLASH_DAMAGE + player.SLASH_DAMAGE_PER_STRENGTH * player.strength
	var damage_dealt = player_slash_damage + player_slash_damage * (charge_up / 100)
	print("Slash damage: "+str(damage_dealt))
	print("Charge modifier: " + str(charge_up / 100))

	if hitbox.has_overlapping_bodies():
		for defender in hitbox.get_overlapping_bodies():
			print("defender: "+str(defender))
			if defender is Enemy:
				Ge.hit_stop(0.1)
				if !defender.chase_target:
					damage_dealt *= 2

				var defender_state = defender.state_node.state.name
				if defender_state == "stance_defensive":
					defender.combat_properties.stun(2.0)
					slash_emitter.set_parameter("AttackResult", "GuardBreak")
				else:
					defender.take_damage(damage_dealt, player, true)
					slash_emitter.set_parameter("AttackResult", "Hit")
				defender.combat_properties.pushback_apply(player.global_position, pushback_force)
			else:
				defender.take_damage(damage_dealt, player)
	else:
		slash_emitter.set_parameter("AttackResult", "Miss")
	
	slash_emitter.play()
