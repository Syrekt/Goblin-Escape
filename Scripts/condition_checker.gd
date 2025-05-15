extends Node2D

@export var condition_target : Node2D
@export var result_target : Node2D

@export var parameters : Array[String] = []
@export var results : Array




func _process(delta: float) -> void:
	if !result_target || !condition_target:
		queue_free()
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
