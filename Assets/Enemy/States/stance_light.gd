extends EnemyState

var take_another_stance = false

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "stance_light")
	enemy.move(0, 0)
	take_another_stance = randi() % 2
	if take_another_stance:
		$Timer.start(1.0)
	else:
		$Timer.start(2.0)
	if !%AttackDetector.has_overlapping_bodies():
		finished.emit("chase")

func exit():
	$Timer.stop()


func update(delta):
	if enemy.chase_target:
		enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))
		if enemy.chase_target.combat_properties.stunned:
			finished.emit("slash")
		elif enemy.chase_target.state_node.state.name == "stance_heavy":
			enemy.counter_attack = true
			finished.emit("stab")
		elif abs(enemy.chase_target.velocity.x) == enemy.chase_target.stance_walk_speed:
			finished.emit("stab")
	else:
		enemy.lost_target()
	if enemy.player_proximity.has_overlapping_bodies():
		enemy.counter_attack = true
		finished.emit("bash")


func _on_timer_timeout() -> void:
	finished.emit(["stab", "stance_heavy", "stance_defensive"].pick_random())
