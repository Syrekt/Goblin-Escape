extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "stun")

func _on_stun_timer_timeout() -> void:
	player.combat_properties.stunned = false
	finished.emit("stance_light")
