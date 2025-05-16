extends EnemyCombatState

func update(delta):
	if enemy.chase_target:
		enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))
		if enemy.chase_target.combat_properties.stunned:
			finished.emit("slash")
		elif enemy.chase_target.state_node.state.name == "stance_heavy":
			enemy.counter_attack = true
			finished.emit("stab")
		elif abs(enemy.chase_target.velocity.x) == enemy.chase_target.stance_walk_speed:
			finished.emit("stab")
	else:
		enemy.lost_target()
		return false

	if enemy.health.value <= 0:
		finished.emit("laugh")

	if enemy.player_proximity.has_overlapping_bodies():
		enemy.counter_attack = true
		finished.emit("bash")
