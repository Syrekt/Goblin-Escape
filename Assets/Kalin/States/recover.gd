extends PlayerState

func enter(previous_state_name: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.unconscious = false
