extends Interaction

var save_effect_scene = load("res://VFX/save_effect.tscn")

func update(player: Player):
	if Input.is_action_just_pressed("interact"):
		Ge.save_game()
		player.smell.value = 0
		player.smell.dirt_amount = 0
		player.arousal.value = 0

		var save_effect : AnimatedSprite2D = save_effect_scene.instantiate()
		save_effect.animation_finished.connect(save_effect.queue_free)
		player.add_child(save_effect)
		player.think("I should be safe now..")
		
		Ge.play_audio_free(0, "res://SFX/water_splash1.wav")
