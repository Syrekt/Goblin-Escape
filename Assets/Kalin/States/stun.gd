extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "stun")

func update(delta: float) -> void:
	if !player.combat_properties.stunned:
		finished.emit("stance_light")
