extends PlayerState

var orgasm_emitter : AudioStreamPlayer2D
var squirt_emitter : AudioStreamPlayer2D
var goblin_emitter : AudioStreamPlayer2D

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", "orgasm_goblin1")

	orgasm_emitter = AudioStreamPlayer2D.new()
	squirt_emitter = AudioStreamPlayer2D.new()
	goblin_emitter = AudioStreamPlayer2D.new()

	owner.add_child(orgasm_emitter)
	owner.add_child(squirt_emitter)
	owner.add_child(goblin_emitter)

func exit() -> void:
	orgasm_emitter.queue_free()
	squirt_emitter.queue_free()
	player.smell.value = move_toward(player.smell.value, 0, 5)
	player.smell.semen_amount += 1

func play_orgasm_sound() -> void:
	Ge.play_audio_from_string_array(orgasm_emitter, 0.0, "res://Sex/Moan/")
func play_squirt_sound() -> void:
	Ge.play_audio_from_string_array(squirt_emitter, 0.0, "res://Sex/Squirt/")
func play_goblin_groan() -> void:
	Ge.play_audio_from_string_array(squirt_emitter, -10.0, "res://SFX/Goblin/Groan")
