extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.animation_player.call_deferred("play", "stun")

func _enter():
	enemy.velocity.x = lerp(enemy.velocity.x, 0, 0.1)

func update(delta: float) -> void:
	if not enemy.combat_properties.stunned:
		enemy.state_node.state.finished.emit("stance_light")
