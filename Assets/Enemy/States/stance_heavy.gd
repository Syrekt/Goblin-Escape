extends EnemyState

var instant := false

func enter(previous_state_path: String, data := {}) -> void:
	instant = data.get("instant", true)
	enemy.call_deferred("update_animation", "stance_heavy")
	enemy.velocity.x = 0
	#Skip if instant
	if instant:
		$Timer.start(0.1)
	else:
		$Timer.start()

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
		finished.emit("slash")
	elif enemy.chase_target.velocity.x != 0:
		finished.emit("stab")


func _on_timer_timeout() -> void:
	enemy.state_node.state.finished.emit("slash")
