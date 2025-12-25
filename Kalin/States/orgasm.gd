extends PlayerState

func enter(previous_state_path : String, data := {}) -> void:
	var anim = player.animation_player.current_animation
	print("Sex animation before orgasm: "+str(anim))
	match player.animation_player.current_animation:
		"struggle_sex_goblin1":
			player.call_deferred("update_animation", "struggle_orgasm_goblin1")
		"lose_sex_goblin1":
			player.call_deferred("update_animation", "lose_orgasm_goblin1")


func exit() -> void:
	player.smell.value = move_toward(player.smell.value, 0, 5)
	player.smell.semen_amount += 1

func play_orgasm_sound() -> void:
	$Moan.play()
func play_squirt_sound() -> void:
	$Squish.play()
func play_goblin_groan() -> void:
	$OrgasmGoblin.play()
