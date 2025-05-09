extends Node

#Direct hit
#Shield break and hit
#Shield hit and stun
#Direct hit and kill


const RESULT_WHIFF := 0
const RESULT_HIT := 1
const RESULT_BLOCK := 2
const RESULT_STUN := 3
const RESULT_DEAD := 4

func deal_damage(attacker: CharacterBody2D, damage: int, defender: CharacterBody2D, pushback_force : int) -> int:
	var defender_state = defender.state_node.state.name;
	var defender_blocking = defender_state == "stance_defensive"
	var result = RESULT_WHIFF

	match attacker.state_node.state.name:
		"slash":
			print("Slash target")
			if defender_blocking:
				print("Attack result: Blocked by opponent")
				defender.combat_properties.stun(2.0)
				result = RESULT_STUN
			else:
				print("Not blocking, deal damage")
				defender.take_damage(damage, attacker)
				result = RESULT_HIT
			defender.combat_properties.pushback_apply(attacker.global_position, pushback_force)
		"stab":
			print("Stab target")
			if defender_blocking:
				print("Attack result: Stun target")
				attacker.combat_properties.stun(2.0)
				if defender is Player:
					if !defender.stamina.spend(1):
						defender.combat_properties.stun(2.0)
				result = RESULT_BLOCK
			elif defender.combat_properties.stunned:
				defender.take_damage(damage * 2, attacker)
				result = RESULT_HIT
			else:
				print("Not blocking, deal damage")
				defender.take_damage(damage, attacker)
				result = RESULT_HIT
			defender.combat_properties.pushback_apply(attacker.global_position, pushback_force)
		"bash":
			print("Attack result: Bash target")
			if attacker is Enemy && attacker.counter_attack:
				defender.combat_properties.pushback_apply(attacker.global_position, pushback_force*5)
				defender.take_damage(0, attacker)
				result = RESULT_HIT
			elif attacker is Player && !defender.in_combat:
				defender.combat_properties.stun(2.0)
				result = RESULT_STUN
			else:
				defender.combat_properties.pushback_apply(attacker.global_position, pushback_force)
				if !defender_blocking:
					defender.take_damage(0, attacker)
					result = RESULT_HIT
		"_":
			defender.take_damage(damage, attacker)
			result = RESULT_HIT
	print("Attacker name: "+str(attacker.name));
	print("Defender name: "+str(defender.name));
	return result
