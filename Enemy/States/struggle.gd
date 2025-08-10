extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	enemy.chase_disabled = true

func exit() -> void:
	enemy.chase_disabled = false

func update(delta: float) -> void:
	enemy.player.global_position.x = enemy.global_position.x + 23*enemy.facing
