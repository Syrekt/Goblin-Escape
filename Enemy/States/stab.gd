extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	if enemy.counter_attack:
		enemy.call_deferred("update_animation", name, 2)
		Ge.play_audio_free(4, "res://SFX/sfx_counter_attack1.wav")
	else:
		enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
func exit() -> void:
	enemy.counter_attack = false

func _on_stab_hitbox_body_entered(defender:Player) -> void:
	defender.take_damage(1, enemy)
	defender.combat_properties.pushback_apply(enemy.global_position, 50)
	if defender.health.value <= 0:
		finished.emit("laugh")
