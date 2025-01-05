extends Node

func deal_damage(attacker: CharacterBody2D, defender: CharacterBody2D, knockback_force : int):
	var defender_state = defender.state_node.state.name;
	var defender_blocking = defender_state == "stance_defensive"

	match attacker.state_node.state.name:
		"slash":
			print("Slash target")
			if defender_blocking:
				print("Attack result: Blocked by opponent")
				Combat.stun(defender)
			else:
				print("Not blocking, deal damage")
				defender.take_damage(attacker.damage)
			defender.combat_properties.pushback_apply(attacker.global_position, knockback_force)
		"stab":
			print("Stab target")
			if defender_blocking:
				print("Attack result: Stun target")
				attacker.combat_properties.stun(2.0)
			else:
				print("Not blocking, deal damage")
				defender.take_damage(attacker.damage)
			defender.combat_properties.pushback_apply(attacker.global_position, knockback_force)
		"bash":
			print("Attack result: Bash target")
			defender.combat_properties.pushback_apply(attacker.global_position, knockback_force)
			if not defender_blocking:
				defender.take_damage(attacker.damage)
		"_":
			defender.take_damage(attacker.damage)
	print("Attacker name: "+str(attacker.name));
	print("Defender name: "+str(defender.name));
