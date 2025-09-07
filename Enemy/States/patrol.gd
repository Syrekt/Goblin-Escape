extends EnemyState


var patrol_dir : int
@onready var timer := $PatrolTimer



func enter(previous_state_path: String, data := {}) -> void:
	if !timer.timeout.is_connected(_on_patrol_timer_timeout):
		timer.timeout.connect(_on_patrol_timer_timeout)
	enemy.velocity.x = 0.0
	#Use timer if we don't have a patrol point
	if !enemy.current_patrol_point:
		timer.start()
	#Don't use timer, we have assigned patrol points
	if enemy.current_patrol_point: 
		patrol_dir = Ge.dir_towards(enemy, enemy.current_patrol_point)
	else:
		if enemy.next_step_free(-enemy.facing):
			patrol_dir = -enemy.facing
		else:
			patrol_dir = enemy.facing
func exit() -> void:
	if timer.timeout.is_connected(_on_patrol_timer_timeout):
		timer.timeout.disconnect(_on_patrol_timer_timeout)
	timer.stop()
func update(delta : float) -> void:
	if enemy.debug:
		Debugger.printui("current_patrol_point: "+str(enemy.current_patrol_point));
	if enemy.current_patrol_point: 
		patrol_dir = Ge.dir_towards(enemy, enemy.current_patrol_point)
	#Decide if we are going to leave the player alone or chase
	if enemy.chase_target:
		if enemy.chase_target.dead:
			finished.emit("leave_player")
		elif enemy.chase_target.unconscious && enemy.chase_target.can_have_sex:
			finished.emit("chase")
		elif !enemy.chase_target.hiding:
			#print("Target in sight, chase target")
			if enemy.debug:
				print("chase target from patrol")
				print("aware: "+str(enemy.aware))
				print("target.invisible: "+str(enemy.chase_target.invisible));
				print("target.hiding: "+str(enemy.chase_target.hiding));
			finished.emit("chase")
	elif enemy.current_patrol_point && patrol_point_reached():
		if enemy.debug: print("patrol point reached")
		finished.emit("idle")
		enemy.update_patrol_point()
	elif !enemy.move(enemy.patrol_move_speed, patrol_dir):
		if enemy.debug: print("Can't move, switch to idle")
		finished.emit("idle")
	else:
		enemy.update_animation("run")

func patrol_point_reached(treshold := 16) -> bool:
	return abs(enemy.current_patrol_point.global_position.x - enemy.global_position.x) < treshold

func _on_patrol_timer_timeout() -> void:
	#print("patrol timer timeout, switch to idle")
	if enemy.debug: print("Patrol timer timeout")
	finished.emit("idle")
	#Idea
	#if enemy.patrol_amount == 0:
	#	enemy.emote_emitter.play("idle")
