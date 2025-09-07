extends EnemyState

var chase_dir := 0;

@onready var emote_timer : Timer = $EmoteTimer

func update(delta):
	#Quit state
	if !enemy.chase_target:
		print("lose target from chase")
		enemy.lost_target()
		return

	#region React to player
	if enemy.chase_target.can_have_sex && (enemy.chase_target.dead || enemy.chase_target.unconscious):
		finished.emit("laugh")
		return
	elif enemy.attack_detector.has_overlapping_bodies():
		if enemy.chase_target.hiding:
			enemy.chase_target.force_unhide()
		if enemy.chase_target.dead || enemy.chase_target.unconscious:
			enemy.update_animation("idle")
			enemy.velocity.x = 0
		else:
			finished.emit(enemy.main_stance.name)
		return
	#endregion

	#If can move, play run animation, idle otherwise
	chase_dir = sign(enemy.chase_target.position.x - enemy.position.x)
	if enemy.move(enemy.move_speed, chase_dir):
		enemy.update_animation("run")
	else:
		enemy.update_animation("idle")
		enemy.velocity.x = 0
