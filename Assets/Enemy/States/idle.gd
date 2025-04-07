extends EnemyState

func enter(previous_state_path : String, data = {}) -> void:
	enemy.call_deferred("update_animation", name)
func update(delta : float) -> void:
	enemy.detect_target()
