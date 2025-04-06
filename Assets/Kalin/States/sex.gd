extends PlayerState

var slap_emitter : AudioStreamPlayer2D
var moan_emitter : AudioStreamPlayer2D

#Counts how many times the animation looped
var animation_counter := 0

func enter(previous_state_path: String, data := {}) -> void:
	slap_emitter = AudioStreamPlayer2D.new()
	moan_emitter = AudioStreamPlayer2D.new()

	get_tree().current_scene.add_child(slap_emitter)
	get_tree().current_scene.add_child(moan_emitter)

func exit() -> void:
	slap_emitter.queue_free()
	moan_emitter.queue_free()


func count_animation() -> void:
	animation_counter += 1
	print("animation_counter: "+str(animation_counter))
	if animation_counter >= 3:
		finished.emit("orgasm")
func play_random_slap_sound() -> void:
	Ge.play_audio_from_string_array(slap_emitter, 1, "res://Assets/Sex/Slap/")
func play_random_moan_sound() -> void:
	Ge.play_audio_from_string_array(moan_emitter, 1, "res://Assets/Sex/Moan/")
