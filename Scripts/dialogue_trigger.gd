extends Area2D

@export var dialogue_resource : DialogueResource
@export var dialogue_start := "start"
@export var BALLOON = preload("res://Objects/balloon.tscn")

@export var repeat := false
@export var auto := false

var active = false
var balloon = null

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended);


#region States
func auto_process() -> void:
	if !active:
		activate()

func manual_process() -> void:
	if !active && Input.is_action_just_pressed("interact"):
		activate()

func activate() -> void:
	if active:
		print("Activating dialogue while it's already active!")

	balloon = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)

	active = true;


func process() -> void:
	if auto:
		auto_process()
	else:
		manual_process()
#endregion
#region Signals
func _on_dialogue_ended(resource: DialogueResource) -> void:
	active = false
	balloon.queue_free()
	if !repeat:
		queue_free()
#engregion
