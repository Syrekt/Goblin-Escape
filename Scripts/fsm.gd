class_name FSM extends Node

@export var initial_state: State = null
var last_state: State = null
var state_timer: Timer

signal state_changed

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()


func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)

	state_timer = Timer.new()
	state_timer.timeout.connect(_on_state_timer_timeout)
	add_child(state_timer)

	await owner.ready
	state.enter("")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	state.elapsed_time = 0
	state_timer.start(0.1)
	if owner.debug:
		print_stack()
	if "states_locked" in owner && owner.states_locked:
		print("States are locked, exiting state transition.")
		return

	if owner.debug:
		print(owner.name,":", state.name, " -> ", target_state_path)
	if !has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	last_state = state
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
	state_changed.emit(state)

func _on_state_timer_timeout() -> void:
	state.elapsed_time += 0.1
