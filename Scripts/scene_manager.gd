extends Node2D

@onready var ground_tiles : TileMapLayer = $BG
@onready var player : Player = $Kalin

var fog_image : Image
var vision_image : Image

signal player_ready

func _enter_tree() -> void:
	player_ready.connect(_on_player_ready)

func _on_player_ready(_player:Player) -> void:
	print("on player ready")
	Ge.player = _player
	for child in get_children():
		if child is Enemy:
			child.assign_player(_player)

func reset_scene() -> void:
	print("Reset scene")
	for child in get_children():
		if child is Enemy:
			child.reset()
