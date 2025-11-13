extends Node2D

@export var condition_target_path : NodePath
@export var result_target_path : NodePath
@export var player_check := true
var condition_target : Node2D
var result_target : Node2D

@export var parameters : Array[String] = []
@export var results : Array


func _ready() -> void:
	hide()

	var game = Game.get_singleton()
	print("Condition check in room %s, condition target: %s - result target: %s" %[game.map.name, condition_target_path, result_target_path])
	if player_check:
		condition_target = Game.get_singleton().player
	else:
		if has_node(condition_target_path):
			condition_target = get_node(condition_target_path)
		else:
			push_error("Condition target path is invalid: " + str(condition_target_path))
	
	if has_node(result_target_path):
		result_target = get_node(result_target_path)
	else:
		push_error("Result target path is invalid: " + str(result_target_path))


func _process(delta: float) -> void:
	if !condition_target:
		print("Can't find result target, free instance")
		queue_free()
	if !result_target:
		print("Can't find resresultult target, free instance")
		queue_free()
	if !is_instance_valid(condition_target) || !is_instance_valid(result_target):
		Debugger.printui("Condition checker invalid targets, " + str(condition_target) + "-" + str(result_target))
		return

	var condition := true
	for i in parameters.size():
		if condition_target.get(parameters[i]) != results[i]:
			condition = false


	if condition:
		result_target.visible = true
		result_target.monitorable = true
	else:
		result_target.visible = false
		result_target.monitorable = false
