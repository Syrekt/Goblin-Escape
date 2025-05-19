extends EnemyCombatState

func update(delta: float):
	if _update(delta): return

	enemy.set_facing(sign(enemy.chase_target.position.x - enemy.position.x))
	if enemy.player_proximity.has_overlapping_bodies():
		finished.emit("slash")
	elif enemy.chase_target.velocity.x != 0:
		finished.emit("stab")
