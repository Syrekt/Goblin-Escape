extends EnemyCombatState

func update(delta):
	if !%AttackDetector.has_overlapping_bodies():
		if enemy.chase_target:
			finished.emit("chase")
		else:
			print("no chase target in heavy")
			enemy.lost_target()
			return

	if enemy.health.value <= 0:
		finished.emit("laugh")

	enemy.set_facing(sign(enemy.chase_target.position.x - enemy.position.x))
	if enemy.player_proximity.has_overlapping_bodies():
		finished.emit("slash")
	elif enemy.chase_target.velocity.x != 0:
		finished.emit("stab")
