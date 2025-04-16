extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "stance_heavy")
	enemy.velocity.x = 0
	$Timer.start(randf_range(1.0, 2.0))

func exit():
	$Timer.stop()

func update(delta):
	if not %AttackDetector.has_overlapping_bodies():
		enemy.state_node.state.finished.emit("patrol")
	enemy.set_facing(sign(enemy.chase_target.position.x - enemy.position.x))
	if enemy.player_proximity.has_overlapping_bodies():
		finished.emit("slash")
	elif enemy.chase_target.velocity.x != 0:
		finished.emit("stab")


func _on_timer_timeout() -> void:
	enemy.state_node.state.finished.emit("slash")
