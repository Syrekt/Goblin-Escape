extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.animation_player.call_deferred("play", "hurt")

func exit():
	enemy.velocity.x = 0

func physics_update(delta: float) -> void:
	if enemy.combat_properties.pushback_timer <= 0:
		enemy.state_node.state.finished.emit("stance_light")
