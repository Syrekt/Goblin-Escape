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
	var moving := false
	if enemy.chase_target:
		if enemy.player_detected():
			enemy.start_chase()
			return
	if enemy.current_patrol_point: 
		patrol_dir = Ge.dir_towards(enemy, enemy.current_patrol_point)
		moving = enemy.move(enemy.patrol_move_speed, patrol_dir)
		if enemy.current_patrol_point && patrol_point_reached():
			if enemy.debug: print("patrol point reached")
			enemy.update_patrol_point()
			finished.emit("idle")
	else:
		moving = enemy.move(enemy.patrol_move_speed, patrol_dir)
		if !moving:
			if enemy.debug: print("Can't move, switch to idle")
			finished.emit("idle")

	if moving:
		enemy.update_animation("run")

func patrol_point_reached(treshold := 16) -> bool:
	var dist = abs(enemy.current_patrol_point.global_position.x - enemy.global_position.x)
	if enemy.debug: Debugger.printui("dist: "+str(dist))
	return abs(enemy.current_patrol_point.global_position.x - enemy.global_position.x) < treshold

func _on_patrol_timer_timeout() -> void:
	#print("patrol timer timeout, switch to idle")
	if enemy.debug: print("Patrol timer timeout")
	finished.emit("idle")
	#Idea
	#if enemy.patrol_amount == 0:
	#	enemy.emote_emitter.play("idle")
