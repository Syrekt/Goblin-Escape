extends EnemyState

func enter(previous_state_path : String, data := {}):
	enemy.call_deferred("update_animation", name)
	enemy.emote_emitter.play("lewd")
	enemy.velocity.x = 0

func play_laugh() -> void:
	enemy.sfx_emitter.set_parameter("EnemySound", "Laugh")
	enemy.sfx_emitter.play()
