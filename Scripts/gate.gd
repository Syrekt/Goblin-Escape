extends Node2D

@onready var shape : CollisionShape2D = get_node("Collider/Shape")
@onready var audio_emitter : AudioStreamPlayer2D = $AudioEmitter
@onready var interaction : Area2D = $Interaction
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var animation_tree : AnimationTree = $AnimationTree

@export var closed := true
@export var key : InventoryItem


func _process(delta: float) -> void:
	var anim = animation_player.current_animation
	var state_machine = animation_tree["parameters/playback"]
	if closed:
		shape.disabled = false
		interaction.monitorable = true
	else:
		shape.disabled = true
		interaction.monitorable = false
