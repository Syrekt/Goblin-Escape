extends EnemyState

var audio_emitter : AudioStreamPlayer2D

func enter(previous_state_path : String, data := {}):
	enemy.call_deferred("update_animation", name)

	audio_emitter = AudioStreamPlayer2D.new()

	enemy.emote_emitter.play("lewd")

func exit() -> void:
	audio_emitter.queue_free()

func play_laugh() -> void:
	Ge.play_audio_from_string_array(audio_emitter, -10, "res://Assets/SFX/Goblin/Laugh/")
