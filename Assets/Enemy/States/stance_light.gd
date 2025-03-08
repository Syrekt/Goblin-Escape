extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "stance_light")
	enemy.move(0, 0)
	$Timer.start(randf_range(1.0, 2.0))
	enemy.slash_hitbox.call_deferred("set_disabled", true)
	enemy.stab_hitbox.call_deferred("set_disabled", true)
	enemy.bash_hitbox.call_deferred("set_disabled", true)

func exit():
	$Timer.stop()


func update(delta):
	if not %AttackDetector.has_overlapping_bodies():
		finished.emit("patrol")
	enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))


func _on_timer_timeout() -> void:
	var next_states = ["stab", "stance_heavy", "stance_defensive"]
	finished.emit(next_states.pick_random())
