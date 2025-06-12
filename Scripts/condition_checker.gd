extends Node2D

@export var condition_target_path : NodePath
@export var result_target_path : NodePath
var condition_target : Node2D
var result_target : Node2D

@export var parameters : Array[String] = []
@export var results : Array


func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if !result_target || !condition_target:
		print("DISABLED: Result target or condition target doesn't exists: " + name)
		if !result_target: result_target = get_node(result_target_path)
		if !condition_target: result_target = get_node(result_target_path)
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
