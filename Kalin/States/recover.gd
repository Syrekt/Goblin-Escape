extends PlayerState

func enter(previous_state_name: String, data := {}) -> void:
	print("Kalin Recovers")
	player.call_deferred("update_animation", name)
	player.can_have_sex = false
	if player.unconscious:
		player.unconscious = false
		player.status_effect_container.add_status_effect("Death's Door")
