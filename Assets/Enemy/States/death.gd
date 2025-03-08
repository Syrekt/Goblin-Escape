extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "death")
	enemy.states_locked = true
	enemy.velocity = Vector2.ZERO
