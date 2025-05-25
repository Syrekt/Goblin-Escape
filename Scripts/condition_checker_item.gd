extends Node2D

@export var player : Player
@export var result_target : Node2D

@export var parameters : Array[Resource] = []
@export var results : Array[bool] = []


func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if !result_target || !player:
		print("Result target or condition target doesn't exists, destroy..")
		queue_free()
		return

	var condition := true
	var inv = player.inventory_panel.inventory
	for i in parameters.size():
		if inv.has_item(parameters[i]) != results[i]:
			condition = false

	if condition:
		result_target.visible = true
		result_target.monitorable = true
	else:
		result_target.visible = false
		result_target.monitorable = false
