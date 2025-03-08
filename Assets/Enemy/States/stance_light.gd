extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.animation_player.call_deferred("play", "stance_light")
	enemy.move(0, 0)
	$Timer.start(randf_range(1.0, 2.0))
	enemy.slash_hitbox.call_deferred("set_disabled", true)
	enemy.stab_hitbox.call_deferred("set_disabled", true)
	enemy.bash_hitbox.call_deferred("set_disabled", true)

func exit():
	print("timer stop")
	$Timer.stop()


func update(delta):
	if not %AttackDetector.has_overlapping_bodies():
		enemy.state_node.state.finished.emit("patrol")
	enemy.set_facing(sign(enemy.chase_target.position.x - enemy.position.x))


func _on_timer_timeout() -> void:
	var next_states = ["stab", "stance_heavy", "stance_defensive"]
	enemy.state_node.state.finished.emit(next_states.pick_random())
