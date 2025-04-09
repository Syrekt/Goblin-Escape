extends EnemyState


var patrol_dir := 1
var move = true


#region Process
func enter(previous_state_path: String, data := {}) -> void:
	enemy.velocity.x = 0.0
	$IdleTimer.start()
	$PatrolTimer.start()
	$PatrolEndTimer.start()
func exit() -> void:
	$IdleTimer.stop()
	$PatrolTimer.stop()
	$PatrolEndTimer.stop()
func update(delta : float) -> void:
	if $PatrolEndTimer.is_stopped():
		%Emote.play("confused")
		finished.emit("idle")
		enemy.velocity = Vector2.ZERO
		return

	Debugger.printui("enemy.chase_target: "+str(enemy.chase_target));
	if enemy.chase_target && enemy.chase_target.unconscious:
		if %ChaseDetector.has_overlapping_bodies():
			enemy.move(enemy.patrol_move_speed, sign(enemy.global_position.x - enemy.chase_target.global_position.x))
			enemy.update_animation("run")
	else:
		patrol(delta)
		enemy.detect_target()
#endregion
#region Methods
func patrol(delta: float):
	if move:
		var moving = enemy.move(enemy.patrol_move_speed, patrol_dir)
		Debugger.printui("moving: "+str(moving))
		Debugger.printui("enemy.velocity.x: "+str(enemy.velocity.x));
		Debugger.printui("patrol_dir: "+str(patrol_dir))

		if moving:
			enemy.update_animation("run")
		else:
			enemy.update_animation("idle")
			move = false
			$PatrolTimer.stop()
			$IdleTimer.start()
	else:
		enemy.update_animation("idle")
		enemy.move(0, 0)
#endregion
#region Listeners
func _on_idle_timer_timeout() -> void:
	patrol_dir *= -1
	move = true
	$PatrolTimer.start()
func _on_patrol_timer_timeout() -> void:
	enemy.velocity.x = 0
	move = false
	$IdleTimer.start()
#endregion
