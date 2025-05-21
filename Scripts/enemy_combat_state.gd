class_name EnemyCombatState extends EnemyState

@export var transitions : Array[EnemyCombatState] ##Transition states from main stance only
@export var attack_state : EnemyState
@export var stance_time := 1.0
@export var attack_time := 0.5
@export var debug_stance : String

var timer : Timer


func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	
	if !%AttackDetector.has_overlapping_bodies():
		finished.emit("chase")
		return

	var is_main_stance = enemy.main_stance == self
	if is_main_stance:
		if randi() % 2:
			timer.timeout.connect(_on_stance_timer_timeout)
			timer.start(stance_time)
		else:
			timer.timeout.connect(_on_attack_timer_timeout)
			timer.start(attack_time)
	else:
		timer.timeout.connect(_on_attack_timer_timeout)
		timer.start(attack_time)

func exit():
	timer.queue_free()

func _update(delta: float) -> bool:
	if !enemy.chase_target:
		enemy.lost_target()
		return true
	elif enemy.chase_target.dead:
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
	if debug_stance != "":
		finished.emit(debug_stance)
	else:
		finished.emit(transitions.pick_random().name)
func _on_attack_timer_timeout() -> void:
	finished.emit(attack_state.name)
