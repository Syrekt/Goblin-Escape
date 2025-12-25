extends PlayerState

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
	player.stamina.spend(0.005, 0.005, false)
	#player.smell.value = move_toward(player.smell.value, player.smell.max_value, delta)
	player.fatigue.add(0.001)


func count_animation() -> void:
	player.arousal.value = move_toward(player.arousal.value, player.arousal.max_value, 1)
	animation_counter += 1
	print("animation_counter: "+str(animation_counter))
	if animation_counter >= animation_number:
		finished.emit("orgasm")
func play_random_slap_sound() -> void:
	$Slap.play()
func play_random_moan_sound() -> void:
	$Moan.play()
