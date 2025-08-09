extends EnemyState

var move_dir : int

func enter(previous_state_path : String, data := {}) -> void:
	enemy.call_deferred("update_animation", "run");
	move_dir = sign(enemy.global_position.x - enemy.player.global_position.x)
	$Timer.start()
func exit() -> void:
	$Timer.stop()

func update(delta: float) -> void:
	if !enemy.move(enemy.patrol_move_speed, move_dir):
		enemy.patrol_amount = 2
		finished.emit("idle")

func _on_timer_timeout() -> void:
	if enemy.debug: print("Leave player")
	enemy.patrol_amount = 2
	finished.emit("idle")
