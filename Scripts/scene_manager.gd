extends Node2D

signal player_ready

func _enter_tree() -> void:
	player_ready.connect(_on_player_ready)

func _on_player_ready(player:Player) -> void:
	Ge.player = player
	for child in $Enemies.get_children():
		if child is Enemy:
			child.assign_player(player)
