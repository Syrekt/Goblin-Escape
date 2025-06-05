extends EnemyCombatState

func update(delta: float):
	if _update(delta): return


	if enemy.chase_target:
		enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))
		if in_combat_range && target_stunned:
			finished.emit("slash")
		elif target_state == "stance_heavy":
			enemy.counter_attack = true
			finished.emit("stab")
	else:
		print("no chase target in light")
		enemy.lost_target()
		return false

	if enemy.player_proximity.has_overlapping_bodies():
		enemy.counter_attack = true
		if get_node_or_null("stance_defensive"):
			finished.emit("bash")
		else:
			finished.emit("slash")
