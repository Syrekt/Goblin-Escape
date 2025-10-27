extends EnemyState

var step_forward : bool
@onready var hitbox : Area2D = get_child(0)

func enter(previous_state_path: String, data := {}) -> void:
	if enemy.counter_attack:
		enemy.call_deferred("update_animation", name, 2)
		Ge.play_audio_free(4, "res://SFX/sfx_counter_attack1.wav")
		var tween = create_tween().bind_node(self)
		tween.tween_property(enemy.sprite.material, "shader_parameter/flash_intensity", 1.0, 0)
		tween.tween_property(enemy.sprite.material, "shader_parameter/flash_intensity", 0.0, 0.2)
	else:
		enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0

	step_forward = data.get("step_forward", false)

func exit() -> void:
	enemy.counter_attack = false
	enemy.velocity.x = 0

func _on_stab_hitbox_body_entered(node: Node2D) -> void:
	for defender in hitbox.get_overlapping_bodies():
		if defender is Player:
			defender.take_damage(enemy.stab_damage, enemy)
			defender.combat_properties.pushback_apply(enemy.global_position, 50)
		else:
			defender.take_damage(enemy.slash_damage, enemy)

func _on_hit_frame() -> void:
	if step_forward:
		enemy.apply_force_x(100.0, 0.5)
