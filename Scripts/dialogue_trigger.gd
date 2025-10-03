extends Interaction

@export var dialogue_resource : DialogueResource
@export var dialogue_start := "start"
@export var BALLOON = preload("res://Objects/balloon.tscn")
@export var camera_focus_path : NodePath
var camera_focus : Node2D

var balloon = null

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended);
	if camera_focus_path: camera_focus = get_node(camera_focus_path)

#region Methods
func activate() -> void:
	Ge.camera_focus = camera_focus
	if active:
		print("Activating dialogue while it's already active!")

	balloon = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)

	active = true;


func update(player : Player) -> void:
	if auto:
		if !active && !waiting_player_exit:
			waiting_player_exit = true
			activate()
	else:
		if !active && Input.is_action_just_pressed("interact"):
			activate()
#endregion
#region Signals
func _on_dialogue_ended(resource: DialogueResource) -> void:
	if active:
		active = false
		if !repeat:
			queue_free()
#engregion
