extends EnemyCombatState

func update(delta: float):
	if _update(delta): return
	var target = enemy.chase_target


	if enemy.has_enemy_in_proximity():
		finished.emit("stance_walk", {"time" : 0.1, "backwards" : true})
		print("Has another enemy in it's proximity detector")
		return

	if enemy.chase_target:
		if target.is_in_sex_state():
			finished.emit("idle")
			return
		if target.unconscious || target.dead:
			finished.emit("chase")
			return
		enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))
		if in_combat_range:
			if target_stunned:
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
		if get_node_or_null("../stance_defensive"):
			finished.emit("bash")
		else:
			finished.emit("slash")
