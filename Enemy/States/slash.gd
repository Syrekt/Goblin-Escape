extends EnemyState

var step_forward : bool
@onready var hitbox : Area2D = get_child(0)

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	step_forward = data.get("step_forward", false)
	print("step_forward: "+str(step_forward))

func update(delta: float) -> void:
	if step_forward:
		enemy.apply_force_x(200, 0.5)

func _on_slash_hitbox_body_entered(node: Node2D) -> void:
	for defender in hitbox.get_overlapping_bodies():
		if defender is Player:
			var defender_state = defender.state_node.state.name

			defender.take_damage(enemy.slash_damage, enemy, true)
			defender.combat_properties.pushback_apply(enemy.global_position, 50)
		else:
			defender.take_damage(enemy.slash_damage, enemy)

