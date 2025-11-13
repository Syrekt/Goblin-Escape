extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.set_collision_layer_value(4, false)
	enemy.set_collision_mask_value(2, false)
	enemy.set_collision_mask_value(4, false)
	enemy.call_deferred("update_animation", "death")
	enemy.states_locked = true
	enemy.velocity.x = 0
	enemy.combat_properties.pushback_reset();
	var children = enemy.get_children()
	for child in children:
		if child is Area2D:
			child.set_deferred("monitoring", false)
			child.set_deferred("monitorable", false)
	
	if !data.get("loading", false):
		Ge.play_audio_from_string_array(enemy.global_position, -10, "res://SFX/Goblin/Death")
		enemy.player.experience.add(enemy.experience_drop)
		Ge.play_audio_free(0, "res://SFX/sfx_experience_drop.wav")

	Ge.UpdateNoiseIndicator()

func exit() -> void:
	var children = enemy.get_children()
	for child in children:
		if child is Area2D:
			child.set_deferred("monitoring", true)
			child.set_deferred("monitorable", true)
	enemy.set_collision_mask_value(1, true)
	enemy.set_collision_mask_value(2, true)
	enemy.set_collision_mask_value(4, true)
	enemy.set_collision_layer_value(4, true)

	Ge.show_noise_this_room = true
