extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0

func _on_slash_hitbox_body_entered(defender:Player) -> void:
	var defender_state = defender.state_node.state.name

	defender.take_damage(2, enemy, true)
	defender.combat_properties.pushback_apply(enemy.global_position, 50)

	if defender.health.value <= 0:
		finished.emit("laugh")
	#Combat.deal_damage(enemy, 1, enemy.chase_target, 50)

