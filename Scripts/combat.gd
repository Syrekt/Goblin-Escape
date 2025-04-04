extends Node

func deal_damage(attacker: CharacterBody2D, damage: int, defender: CharacterBody2D, pushback_force : int) -> int:
	var defender_state = defender.state_node.state.name;
	var defender_blocking = defender_state == "stance_defensive"

	match attacker.state_node.state.name:
		"slash":
			print("Slash target")
			if defender_blocking:
				print("Attack result: Blocked by opponent")
				defender.combat_properties.stun(2.0)
			else:
				print("Not blocking, deal damage")
				defender.take_damage(damage)
			defender.combat_properties.pushback_apply(attacker.global_position, pushback_force)
		"stab":
			print("Stab target")
			if defender_blocking:
				print("Attack result: Stun target")
				attacker.combat_properties.stun(2.0)
				if defender is Player:
					if !defender.stamina.spend(1):
						defender.combat_properties.stun(2.0)
			elif defender.combat_properties.stunned:
				defender.take_damage(damage * 2)
			else:
				print("Not blocking, deal damage")
				defender.take_damage(damage)
			defender.combat_properties.pushback_apply(attacker.global_position, pushback_force)
		"bash":
			print("Attack result: Bash target")
			if attacker is Enemy && attacker.push_player:
				defender.combat_properties.pushback_apply(attacker.global_position, pushback_force*5)
				defender.take_damage(0)
				attacker.push_player = false
			else:
				defender.combat_properties.pushback_apply(attacker.global_position, pushback_force)
				if !defender_blocking:
					defender.take_damage(damage)
		"_":
			defender.take_damage(damage)
	print("Attacker name: "+str(attacker.name));
	print("Defender name: "+str(defender.name));
	return defender.health.value
