extends EnemyState


var patrol_dir : int


func enter(previous_state_path: String, data := {}) -> void:
	enemy.velocity.x = 0.0
	$PatrolTimer.start()
	patrol_dir = -enemy.facing
	enemy.call_deferred("update_animation", "run")
func exit() -> void:
	$PatrolTimer.stop()
func update(delta : float) -> void:
	#Decide if we are going to leave the player alone or chase
	if enemy.chase_target:
		if enemy.chase_target.unconscious:
			finished.emit("leave_player")
		elif !enemy.target_obstructed():
			finished.emit("chase")
	elif !enemy.move(enemy.patrol_move_speed, patrol_dir):
		finished.emit("idle")

func _on_patrol_timer_timeout() -> void:
	finished.emit("idle")
	#Idea
	#if enemy.patrol_amount == 0:
	#	%Emote.play("idle")
