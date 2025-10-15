extends EnemyState

var chase_dir := 0;

@onready var emote_timer : Timer = $EmoteTimer

func update(delta):
	var target = enemy.chase_target

	#Quit state
	if !target:
		print("lose target from chase")
		enemy.lost_target()
		return

	#region React to player
	# If dead or unconscious
	if target.unconscious:
		print("target dead or unconscious")
		finished.emit("laugh")
		return
	if enemy.attack_detector.has_overlapping_bodies():
		# If in combat range
		
		if target.hiding:
			# If Kalin hides in front of the enemy, unhide her
			target.force_unhide()
		elif !target.dead && !target.unconscious:
			# Target is alive so take stance
			finished.emit(enemy.main_stance.name)
		elif target.unconscious && target.can_have_sex:
			# Allow player controller to play the sex animation
			enemy.update_animation("idle")
			enemy.velocity.x = 0
		return
	#endregion

	#If can move, play run animation, idle otherwise
	chase_dir = sign(enemy.chase_target.position.x - enemy.position.x)
	if enemy.move(enemy.chase_move_speed, chase_dir):
		enemy.update_animation("run")
	else:
		enemy.update_animation("idle")
		enemy.velocity.x = 0
