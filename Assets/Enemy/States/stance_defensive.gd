extends EnemyState

var take_another_stance := false

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "stance_defensive")
	enemy.velocity.x = 0
	take_another_stance = randi() % 2
	if take_another_stance:
		$Timer.start(1.0)
	else:
		$Timer.start(0.5)
	if !%AttackDetector.has_overlapping_bodies():
		finished.emit("chase")

func exit():
	$Timer.stop()

func update(delta):
	if !%AttackDetector.has_overlapping_bodies():
		if enemy.chase_target:
			finished.emit("chase")
		else:
			enemy.lost_target()
			return

	if enemy.health.value <= 0:
		finished.emit("laugh")

	enemy.set_facing(sign(enemy.chase_target.position.x - enemy.position.x))
	if enemy.player_proximity.has_overlapping_bodies():
		enemy.counter_attack = true
		finished.emit("bash")
	elif enemy.chase_target.velocity.x != 0:
		finished.emit("stab")


func _on_timer_timeout() -> void:
	if take_another_stance:
		finished.emit(["stance_heavy", "stance_light"].pick_random())
	else:
		enemy.state_node.state.finished.emit("bash")
