extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.animation_player.play("stance_heavy")
	enemy.velocity.x = 0
	$Timer.start(randf_range(1.0, 2.0))


func update(delta):
	pass


func _on_timer_timeout() -> void:
	enemy.state_node.state.finished.emit("slash")
