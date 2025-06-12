extends Node2D

@export var player_path : NodePath
@export var result_target_path : NodePath
var player : Player
var result_target : Node2D

@export var parameters : Array[Resource] = []
@export var results : Array[bool] = []


func _ready() -> void:
	hide()
	player = get_node(player_path)


func _process(delta: float) -> void:
	if !result_target || !player:
		Debugger.printui("DISABLED: Result target or condition target doesn't exists: " + name)
		if !result_target: result_target = get_node(result_target_path)
		if !player: player = get_node(player_path)
		Debugger.printui("result_target: "+str(result_target))
		Debugger.printui("player: "+str(player))
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
