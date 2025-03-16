extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "death")
	enemy.states_locked = true
	enemy.velocity = Vector2.ZERO
	Ge.play_audio_from_string_array(enemy.audio_emitter, -10, "res://Assets/SFX/Goblin/Death")
	var children = enemy.get_children()
	for child in children:
		if child is Area2D:
			child.monitoring = false
