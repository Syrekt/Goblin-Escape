extends PlayerState

var slap_emitter : AudioStreamPlayer2D
var moan_emitter : AudioStreamPlayer2D

@export var animation_counter_max := 6
@export var animation_counter_min := 3
var animation_number : int

#Counts how many times the animation looped
var animation_counter := 0

func enter(previous_state_path: String, data := {}) -> void:
	animation_number = randi_range(animation_counter_min, animation_counter_max)

func exit() -> void:
	animation_counter = 0

func update(delta : float) -> void:
	player.arousal.value = move_toward(player.arousal.value, player.arousal.max_value, delta)
	player.smell.value = move_toward(player.smell.value, 0, delta)


func count_animation() -> void:
	player.arousal.value = move_toward(player.arousal.value, player.arousal.max_value, 1)
	animation_counter += 1
	print("animation_counter: "+str(animation_counter))
	if animation_counter >= animation_number:
		finished.emit("orgasm")
func play_random_slap_sound() -> void:
	Ge.play_audio_from_string_array(player.global_position, 0, "res://Sex/Slap/")
func play_random_moan_sound() -> void:
	Ge.play_audio_from_string_array(player.global_position, 0, "res://Sex/Moan/")
