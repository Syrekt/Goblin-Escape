extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "stun")

func _enter():
	enemy.velocity.x = lerp(enemy.velocity.x, 0, 0.1)

func update(delta: float) -> void:
	if !enemy.combat_properties.stunned:
		finished.emit("stance_light")
