extends EnemyCombatState

func update(delta: float):
	if _update(delta): return

	if enemy.player_proximity.has_overlapping_bodies():
		enemy.counter_attack = true
		finished.emit("bash")
	elif enemy.chase_target.velocity.x != 0:
		finished.emit("stab")
