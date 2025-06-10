extends EnemyState

func enter(previous_state_path : String, data = {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	#Can patrol even if patrolling is set to false, will idle after patrol_amount == 0
	if enemy.patrol_amount || enemy.patrolling:
		$IdleTimer.start()
func exit() -> void:
	$IdleTimer.stop()

func update(delta : float) -> void:
	if enemy.chatting:
		if enemy.friend:
			finished.emit("chat_lead")
		else:
			finished.emit("chat_secondary")
		return
	if enemy.chase_target && await enemy.detect_player(enemy.chase_target):
		finished.emit("chase")
		return

func _on_idle_timer_timeout() -> void:
	if enemy.patrol_amount > 0:
		enemy.patrol_amount -= 1
	finished.emit("patrol")
