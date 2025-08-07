extends Node2D

@export var player_path : NodePath
@export var result_target_path : NodePath
var player : Player
var result_target : Node2D

@export var parameters : Array[Resource] = []
@export var results : Array[bool] = []


func _ready() -> void:
	hide()

	if has_node(player_path):
		player = get_node(player_path)
	else:
		push_error("Player path is invalid: " + str(player_path))
	
	if has_node(result_target_path):
		result_target = get_node(result_target_path)
	else:
		push_error("Result target path is invalid: " + str(result_target_path))


func _process(delta: float) -> void:
	if !is_instance_valid(player) || !is_instance_valid(result_target):
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
