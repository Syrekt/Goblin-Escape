extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	if enemy.push_player:
		enemy.call_deferred("update_animation", name, 1.5)
	else:
		enemy.call_deferred("update_animation", name)

func exit() -> void:
	enemy.push_player = false

func _on_bash_hitbox_body_entered(defender:Player) -> void:
	var defender_state = defender.state_node.state.name

	if enemy.push_player:
		defender.combat_properties.pushback_apply(enemy.global_position, 500)
	else:
		defender.combat_properties.pushback_apply(enemy.global_position, 100)
		if !defender_state == "stance_defensive":
			defender.take_damage(1, enemy)
	#Combat.deal_damage(enemy, 1, enemy.chase_target, 100)
