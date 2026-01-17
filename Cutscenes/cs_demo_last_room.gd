extends Area2D

@export var BALLOON = preload("res://Objects/balloon.tscn")
@export var dialogue_resource : DialogueResource

var player	: Player
var cam		: PhantomCamera2D


@export var tunnels : Array[GoblinSpawnTunnel]
@export var shaman	: CharacterBody2D

@export var player_move_target1 : Area2D
@export var player_move_target2 : Area2D

func _ready() -> void:
	if Game.get_singleton().persistent_values.get("met_graktu"):
		queue_free()

func move(actor,target) -> void:
	var dir = sign(target.position.x - actor.position.x)
	actor.move(dir)
	await target.body_entered
	actor.stop()


func move_player(target) -> void:
	var dir = sign(target.position.x - player.position.x)
	player.remote_control_input.append("left")
	await target.body_entered
	player.remote_control_input.erase("left")
	
func fade_out_shaman() -> void:
	var anim_player : AnimationPlayer = shaman.anim_player
	anim_player.play("fade_out")
	await anim_player.animation_finished
	shaman.queue_free()

func spawn_goblins() -> void:
	for tunnel in tunnels:
		tunnel.spawn_enemy.emit()
func begin_scene() -> void:
	cam.follow_mode = cam.FollowMode.GROUP
	cam.set_follow_targets([player, shaman] as Array[Node2D])
func end_scene() -> void:
	cam.follow_mode = cam.FollowMode.SIMPLE
	queue_free()
	var game = Game.get_singleton()
	game.persistent_values.set("met_graktu", true)

func _on_body_entered(body: Node2D) -> void:
	DialogueManager.get_current_scene = func(): return self
	player = body
	cam = player.pcam

	var balloon := BALLOON.instantiate()
	add_sibling(balloon)
	balloon.start(dialogue_resource, "start")

func kalin_think(thought:String) -> void:
	player.think(thought)
