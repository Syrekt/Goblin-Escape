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

func exit():
	$Timer.stop()


func update(delta):
	if !%AttackDetector.has_overlapping_bodies():
		finished.emit("patrol")
	if enemy.chase_target:
		enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))
	if enemy.player_proximity.has_overlapping_bodies():
		enemy.push_player = true
		finished.emit("bash")


func _on_timer_timeout() -> void:
	finished.emit(["stab", "stance_heavy", "stance_defensive"].pick_random())
