extends EnemyCombatState

func update(delta: float):
	if _update(delta): return


	if enemy.chase_target:
		enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))
		if enemy.chase_target.combat_properties.stunned:
			finished.emit("slash")
		elif enemy.chase_target.state_node.state.name == "stance_heavy":
			enemy.counter_attack = true
			finished.emit("stab")
	else:
		print("no chase target in light")
		enemy.lost_target()
		return false

	if enemy.player_proximity.has_overlapping_bodies():
		enemy.counter_attack = true
		finished.emit("bash")
