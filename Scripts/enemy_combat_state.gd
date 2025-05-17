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

func _on_stance_timer_timeout() -> void:
	print("Stance timer owner name: "+str($StanceTimer.owner.name));
	print("$StanceTimer: "+str($StanceTimer.name));
	finished.emit(transitions.pick_random().name)
func _on_attack_timer_timeout() -> void:
	print("Attach timer owner name: "+str($AttackTimer.owner.name));
	print("$AttackTimer: "+str($AttackTimer.name));
	finished.emit(attack_state.name)
