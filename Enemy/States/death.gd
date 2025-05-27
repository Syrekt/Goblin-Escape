extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "death")
	enemy.states_locked = true
	enemy.velocity.x = 0
	Ge.play_audio_from_string_array(enemy.global_position, -10, "res://SFX/Goblin/Death")
	var children = enemy.get_children()
	for child in children:
		if child is Area2D:
			child.set_deferred("monitoring", false)
