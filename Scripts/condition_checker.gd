extends Node2D

@export var condition_target_path : NodePath
@export var result_target_path : NodePath
var condition_target : Node2D
var result_target : Node2D

@export var parameters : Array[String] = []
@export var results : Array


func _ready() -> void:
	hide()

	if has_node(condition_target_path):
		condition_target = get_node(condition_target_path)
	else:
		push_error("condition_target path is invalid: " + str(condition_target_path))
	
	if has_node(result_target_path):
		result_target = get_node(result_target_path)
	else:
		push_error("Result target path is invalid: " + str(result_target_path))


func _process(delta: float) -> void:
	if !is_instance_valid(condition_target) || !is_instance_valid(result_target):
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
