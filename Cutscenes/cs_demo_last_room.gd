extends Area2D

@export var BALLOON = preload("res://Objects/balloon.tscn")
@export var dialogue_resource : DialogueResource

var player	: Player


@export var tunnels : Array[GoblinSpawnTunnel]
@export var shaman	: CharacterBody2D

@export var player_move_target : Area2D
@export var shaman_move_target : Area2D

func move(actor,target) -> void:
	var dir = sign(target.position.x - actor.position.x)
	actor.move(dir)
	await target.body_entered


func move_player(target) -> void:
	var dir = sign(target.position.x - player.position.x)
	player.remote_control_input.append("left")
	await target.body_entered
	player.remote_control_input.erase("left")


func spawn_goblins() -> void:
	for tunnel in tunnels:
		tunnel.spawn_enemy.emit()


func _on_body_entered(body: Node2D) -> void:
	DialogueManager.get_current_scene = func(): return self
	player = body

	var balloon := BALLOON.instantiate()
	add_sibling(balloon)
	balloon.start(dialogue_resource, "start")
