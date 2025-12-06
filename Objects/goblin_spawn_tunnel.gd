class_name GoblinSpawnTunnel extends Interaction


@export var enemy : PackedScene

signal spawn_enemy


func _ready() -> void:
	spawn_enemy.connect(_on_spawn_enemy)

func _on_spawn_enemy() -> void:
	print("Spawn enemy: " + str(enemy))
	var _enemy := enemy.instantiate()
	_enemy.global_position = global_position
	_enemy.assign_player(Game.get_singleton().player)
	add_sibling(_enemy)
