extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "hurt")
	enemy.velocity.x = 0
	#var anim_duration = enemy.animation_player.current_animation_length
	#enemy.animation_player.speed_scale = anim_duration / enemy.combat_properties.pushback_duration

func exit():
	enemy.velocity.x = 0
	#enemy.animation_player.speed_scale = 1.0
