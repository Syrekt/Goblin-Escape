class_name EnemyCombatState extends EnemyState

@export var transitions : Array[EnemyCombatState] ##Transition states from main stance only. WARNING: Might choose to attack instead of changing stance
@export var attack_state : Array[EnemyState]
@export var stance_time := 1.0
@export var attack_time := 0.5
@export var debug_stance : String ##Debug stance to transition on stance timer timeout

var timer : Timer
var in_combat_range := false
var target_stunned := false
var target_state : String


func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0
	
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	

	var is_main_stance = enemy.main_stance == self
	if is_main_stance:
		if randi() % 2:
			timer.timeout.connect(_on_stance_timer_timeout)
			timer.start(stance_time)
		else:
			timer.timeout.connect(_on_attack_timer_timeout)
			timer.start(attack_time)
			if enemy.debug: print("timer.time_left: "+str(timer.time_left));
	else:
		timer.timeout.connect(_on_attack_timer_timeout)
		timer.start(attack_time)

func exit():
	timer.stop()
	if timer.timeout.is_connected(_on_stance_timer_timeout):
		timer.timeout.disconnect(_on_stance_timer_timeout)
	if timer.timeout.is_connected(_on_attack_timer_timeout):
		timer.timeout.disconnect(_on_attack_timer_timeout)
	timer.queue_free()

func _update(delta: float) -> bool:
	if !enemy.chase_target:
		enemy.lost_target()
		return true
	elif enemy.chase_target.dead:
		finished.emit("laugh")
		return true
	in_combat_range = enemy.attack_detector.has_overlapping_bodies()
	target_stunned = enemy.chase_target.combat_properties.stunned
	target_state = enemy.chase_target.state_node.state.name
	#elif abs(enemy.chase_target.velocity.x) >= 30:
	#	finished.emit(attack_state.name)
	#elif !enemy.attack_detector.has_overlapping_bodies():
	#	if enemy.chase_target:
	#		finished.emit("chase")
	#		return true
	#	else:
	#		print("no chase target in heavy")
	#		enemy.lost_target()
	#		return true

	enemy.set_facing(sign(enemy.chase_target.global_position.x - enemy.global_position.x))

	return false


#There is a chance to attack or switch to another combat state
func _on_stance_timer_timeout() -> void:
	if enemy.debug: print("Stance timer timeout");
	if !enemy.attack_detector.has_overlapping_bodies():
		if enemy.global_position.distance_to(enemy.chase_target.global_position) > 64:
			finished.emit("chase")
		else:
			finished.emit(attack_state.pick_random().name, {"step_forward": true})
		return
	enemy.wait_animation_transition = true
	if debug_stance != "":
		finished.emit(debug_stance)
	else:
		finished.emit(transitions.pick_random().name)
func _on_attack_timer_timeout() -> void:
	if enemy.debug: print("Attack timer timeout");
	if !enemy.attack_detector.has_overlapping_bodies():
		if enemy.global_position.distance_to(enemy.chase_target.global_position) > 64:
			finished.emit("chase")
		else:
			finished.emit(attack_state.pick_random().name, {"step_forward": true})
		return
	enemy.wait_animation_transition = true
	finished.emit(attack_state.pick_random().name)
