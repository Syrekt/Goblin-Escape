extends Node2D


@onready var shape : CollisionShape2D = get_node("Collider/Shape")
@onready var audio_emitter : AudioStreamPlayer2D = $AudioEmitter
@onready var interaction : Area2D = $Interaction
@onready var animation_player : AnimationPlayer = $AnimationPlayer

@onready var anim_tree	: AnimationTree = $AnimationTree
@onready var state		: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")


@export var closed := true

@export_multiline var closed_dialogue : String
@export_multiline var custom_thought : String



func _ready() -> void:
	anim_tree.active = false
	var save_data = Game.get_singleton().get_data_in_room(name)
	if save_data:
		closed = save_data.get("closed", closed)
		check_and_toggle_gate()
	state.start("closed" if closed else "open")
	anim_tree.active = true

func _on_gate_toggled() -> void:
	closed = !closed
	Game.get_singleton().save_data_in_room(name, {"closed": closed})

	check_and_toggle_gate()

func check_and_toggle_gate() -> void:
	if closed:
		shape.disabled = false
		interaction.monitorable = true
	else:
		shape.disabled = true
		interaction.monitorable = false
