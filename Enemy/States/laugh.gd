extends EnemyState

func enter(previous_state_path : String, data := {}):
	enemy.call_deferred("update_animation", name)
	enemy.emote_emitter.play("lewd")
	enemy.velocity.x = 0

func play_laugh() -> void:
	Ge.play_audio_from_string_array(enemy.audio_emitter, -10, "res://SFX/Goblin/Laugh/")
