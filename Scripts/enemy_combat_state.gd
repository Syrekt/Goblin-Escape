class_name EnemyCombatState extends EnemyState

@export var transitions : Array[EnemyCombatState] ##Transition states from main stance only
@export var attack_state : EnemyState


func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	
	if !%AttackDetector.has_overlapping_bodies():
		finished.emit("chase")
		return

	var is_main_stance = enemy.main_stance == self
	if is_main_stance:
		if randi() % 2:
			$StanceTimer.start()
		else:
			$AttackTimer.start()
	else:
		$AttackTimer.start()

func exit():
	$StanceTimer.stop()
	$AttackTimer.stop()

func _update(delta: float) -> bool:
	if !enemy.chase_target:
		enemy.lost_target()
		return true
	elif enemy.chase_target.unconscious:
		finished.emit("laugh")
		return true
	#elif abs(enemy.chase_target.velocity.x) >= 30:
	#	finished.emit(attack_state.name)
	#elif !%AttackDetector.has_overlapping_bodies():
	#	if enemy.chase_target:
	#		finished.emit("chase")
	#		return true
	#	else:
	#		print("no chase target in heavy")
	#		enemy.lost_target()
	#		return true

	enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))
	return false


func _on_stance_timer_timeout() -> void:
	finished.emit(transitions.pick_random().name)
func _on_attack_timer_timeout() -> void:
	finished.emit(attack_state.name)
