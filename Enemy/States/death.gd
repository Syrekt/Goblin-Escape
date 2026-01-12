extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	var loading = data.get("loading", false)
	var anim = data.get("animation", "death")
	var anim_player = enemy.animation_player

	if loading:
		anim_player.play(anim)
		anim_player.seek(anim_player.current_animation_length, true)
	else:
		enemy.call_deferred("update_animation", data.get("animation", "death"))

	enemy.set_collision_layer_value(4, false)
	enemy.set_collision_mask_value(2, false)
	enemy.set_collision_mask_value(4, false)
	enemy.states_locked = true
	enemy.is_dead = true
	enemy.velocity.x = 0
	enemy.combat_properties.pushback_reset()
	var children = enemy.get_children()
	for child in children:
		if child is Area2D:
			child.set_deferred("monitoring", false)
			child.set_deferred("monitorable", false)
	
	if !data.get("loading", false):
		enemy.sfx_emitter.set_parameter("EnemySound", "Death")
		enemy.sfx_emitter.play()
		enemy.player.experience.add(enemy.experience_drop)
		enemy.player.experience_drop_sfx.play()

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

	enemy.is_dead = false
