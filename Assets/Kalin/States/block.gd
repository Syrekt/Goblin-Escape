extends PlayerState

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	Ge.play_audio_from_string_array(player.audio_emitter, 1.0, "res://Assets/SFX/Sword block")
