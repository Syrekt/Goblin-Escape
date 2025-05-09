extends EnemyState


var patrol_dir : int


func enter(previous_state_path: String, data := {}) -> void:
	enemy.velocity.x = 0.0
	$PatrolTimer.start()
	patrol_dir = -enemy.facing
func exit() -> void:
	$PatrolTimer.stop()
func update(delta : float) -> void:
	#Decide if we are going to leave the player alone or chase
	if enemy.chase_target && !enemy.target_obstructed(enemy.chase_target):
		if enemy.chase_target.unconscious:
			finished.emit("leave_player")
		else:
			print("Target in sight, chase target")
			finished.emit("chase")
	elif !enemy.move(enemy.patrol_move_speed, patrol_dir):
		#print("Can't move, switch to idle")
		finished.emit("idle")
	else:
		enemy.update_animation("run")

func _on_patrol_timer_timeout() -> void:
	#print("patrol timer timeout, switch to idle")
	finished.emit("idle")
	#Idea
	#if enemy.patrol_amount == 0:
	#	enemy.emote_emitter.play("idle")
