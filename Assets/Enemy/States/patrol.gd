extends EnemyState


var patrol_dir := 1
var move = true

func patrol(delta: float):
	if move:
		var moving = enemy.move(patrol_dir, delta)

		if not moving:
			$PatrolTimer.stop()
			$IdleTimer.start()

func enter(previous_state_path: String, data := {}) -> void:
	enemy.velocity.x = 0.0
	enemy.state_switch_timer.start(randf_range(0.5, 1.0))

func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	if enemy.state_switch_timer.time_left > 0:
		return

	patrol(delta)
	if %ChaseDetector.has_overlapping_bodies():
		var body = %ChaseDetector.get_overlapping_bodies()[0]
		enemy.chase_target = body
		enemy.state_node.state.finished.emit("chase")

func _on_idle_timer_timeout() -> void:
	patrol_dir *= -1
	move = true
	$PatrolTimer.start()


func _on_patrol_timer_timeout() -> void:
	enemy.velocity.x = 0
	move = false
	$IdleTimer.start()
