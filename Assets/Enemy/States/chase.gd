extends EnemyState

var chase_dir := 0;

func update(delta):
	#Quit state
	if !enemy.chase_target || enemy.target_obstructed():
		enemy.lost_target()
		return

	#If can move, play run animation, idle otherwise
	chase_dir = sign(enemy.chase_target.position.x - enemy.position.x)
	if enemy.move(enemy.move_speed, chase_dir):
		enemy.update_animation("run")
	else:
		enemy.update_animation("idle")

	#React to player
	if enemy.chase_target.unconscious:
		finished.emit("leave_player")
	elif %AttackDetector.has_overlapping_bodies():
		if enemy.chase_target.dead || enemy.chase_target.unconscious:
			enemy.update_animation("idle")
		else:
			finished.emit("stance_light")
