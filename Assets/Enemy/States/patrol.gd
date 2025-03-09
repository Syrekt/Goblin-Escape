extends EnemyState


var patrol_dir := 1
var move = true

func patrol(delta: float):
	if move:
		var moving = enemy.move(enemy.patrol_move_speed, patrol_dir)

		if moving:
			enemy.animation_player.play("run")
		else:
			enemy.animation_player.play("idle")
			move = false
			$PatrolTimer.stop()
			$IdleTimer.start()
	else:
		enemy.animation_player.play("idle")
		enemy.move(0, 0)

func enter(previous_state_path: String, data := {}) -> void:
	enemy.velocity.x = 0.0
	enemy.state_switch_timer.start(randf_range(0.5, 1.0))

func physics_update(delta: float) -> void:
	if enemy.state_switch_timer.time_left > 0:
		return

	patrol(delta)
	
	if enemy.chase_target:
		var body = enemy.chase_target
		enemy.line_of_sight.target_position = enemy.line_of_sight.to_local(body.global_position)
		if enemy.line_of_sight.is_colliding():
			enemy.chase_target.combat_target = null
			enemy.chase_target = null
		else:
			finished.emit("chase")



func _on_idle_timer_timeout() -> void:
	patrol_dir *= -1
	move = true
	$PatrolTimer.start()


func _on_patrol_timer_timeout() -> void:
	enemy.velocity.x = 0
	move = false
	$IdleTimer.start()


func _on_chase_detector_body_entered(body: Node2D) -> void:
	#Check ray for obstacles
	enemy.line_of_sight.target_position = enemy.line_of_sight.to_local(body.global_position)
	if !enemy.line_of_sight.is_colliding():
		print("body: "+str(body.name))
		enemy.chase_target = body
		body.combat_target = enemy


func _on_chase_detector_body_exited(body: Node2D) -> void:
	if body == enemy.chase_target:
		enemy.chase_target.combat_target = null
		enemy.chase_target = null
