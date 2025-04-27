extends EnemyState

func enter(previous_state_path : String, data = {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	if enemy.patrol_amount || enemy.patrolling:
		$IdleTimer.start()
func exit() -> void:
	$IdleTimer.stop()

func update(delta : float) -> void:
	if enemy.chase_target && !enemy.target_obstructed():
		finished.emit("chase")

func _on_idle_timer_timeout() -> void:
	if enemy.patrol_amount > 0:
		enemy.patrol_amount -= 1
	finished.emit("patrol")
