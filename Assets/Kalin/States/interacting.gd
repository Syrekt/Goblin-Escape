extends PlayerState


func enter(previous_path_string: String, data := {}) -> void:
	player.call_deferred("update_animation", "idle")
