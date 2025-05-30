extends PlayerState

var orgasm_emitter : AudioStreamPlayer2D
var squirt_emitter : AudioStreamPlayer2D
var goblin_emitter : AudioStreamPlayer2D

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", "orgasm_goblin1")

func exit() -> void:
	player.smell.value = move_toward(player.smell.value, 0, 5)
	player.smell.semen_amount += 1

func play_orgasm_sound() -> void:
	Ge.play_audio_from_string_array(player.global_position, 0.0, "res://Sex/Moan/")
func play_squirt_sound() -> void:
	Ge.play_audio_from_string_array(player.global_position, 0.0, "res://Sex/Squirt/")
func play_goblin_groan() -> void:
	Ge.play_audio_from_string_array(player.global_position, -10.0, "res://SFX/Goblin/Groan")
