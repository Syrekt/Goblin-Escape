extends EnemyState

var step_forward : bool

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	step_forward = data.get("step_forward", false)
	print("step_forward: "+str(step_forward))

func update(delta: float) -> void:
	if step_forward:
		enemy.move(4, enemy.facing)

func _on_slash_hitbox_body_entered(defender:Player) -> void:
	var defender_state = defender.state_node.state.name

	defender.take_damage(enemy.slash_damage, enemy, true)
	defender.combat_properties.pushback_apply(enemy.global_position, 50)

