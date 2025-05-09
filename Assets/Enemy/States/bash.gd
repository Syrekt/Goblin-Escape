extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	if enemy.counter_attack:
		enemy.call_deferred("update_animation", name, 2)
	else:
		enemy.call_deferred("update_animation", name)

func exit() -> void:
	enemy.counter_attack = false

func _on_bash_hitbox_body_entered(defender:Player) -> void:
	var defender_state = defender.state_node.state.name

	if enemy.counter_attack:
		if defender is Player:
			if defender.ray_behind.is_colliding():
				enemy.combat_properties.pushback_apply(defender.global_position, 200)
			else:
				defender.combat_properties.pushback_apply(enemy.global_position, 500)
		defender.take_damage(0, enemy)
	else:
		if defender is Player:
			if defender.ray_behind.is_colliding():
				enemy.combat_properties.pushback_apply(defender.global_position, 100)
			else:
				defender.combat_properties.pushback_apply(enemy.global_position, 100)
		if !defender_state == "stance_defensive":
			defender.take_damage(1, enemy)
