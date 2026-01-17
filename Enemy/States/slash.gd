extends EnemyState

@onready var hitbox : Area2D = get_child(0)

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	if !enemy.chase_target: return

	if !enemy.chase_target.col_behind.has_overlapping_bodies() && enemy.should_step_on_attack():
		enemy.apply_force_x(50, 0.5)

func _on_slash_hitbox_body_entered(node: Node2D) -> void:
	for defender in hitbox.get_overlapping_bodies():
		if defender is Player:
			var defender_state = defender.state_node.state.name

			defender.take_damage(enemy.slash_damage, enemy, true)
			defender.combat_properties.pushback_apply(enemy.global_position, 50)
			defender.status_effect_container.add_status_effect("Bleed", 30.0, 0.5)
		else:
			defender.take_damage(enemy.slash_damage, enemy)
