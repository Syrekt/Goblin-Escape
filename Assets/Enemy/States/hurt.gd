extends EnemyState


func enter(previous_state_path: String, data := {}) -> void:
	enemy.animation_player.call_deferred("play", "hurt")
	var anim_duration = enemy.animation_player.current_animation_length
	print("anim_duration: "+str(anim_duration))
	enemy.animation_player.speed_scale = anim_duration / enemy.combat_properties.pushback_duration
	print("Speed scale: "+str(enemy.animation_player.speed_scale));

func exit():
	enemy.velocity.x = 0
	enemy.animation_player.speed_scale = 1.0

func physics_update(delta: float) -> void:
	if enemy.combat_properties.pushback_timer <= 0:
		enemy.state_node.state.finished.emit("stance_light")
