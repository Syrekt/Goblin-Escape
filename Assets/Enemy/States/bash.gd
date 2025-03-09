extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	if enemy.push_player:
		enemy.call_deferred("update_animation", "bash", 1.5)
	else:
		enemy.call_deferred("update_animation", "bash")
