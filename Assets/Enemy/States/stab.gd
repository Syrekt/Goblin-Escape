extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	if enemy.counter_attack:
		enemy.call_deferred("update_animation", name, 2)
	else:
		enemy.call_deferred("update_animation", name)

func _on_stab_hitbox_body_entered(defender:Player) -> void:
	defender.take_damage(1, enemy)
	defender.combat_properties.pushback_apply(enemy.global_position, 50)
	#Combat.deal_damage(enemy, 1, enemy.chase_target, 50)
