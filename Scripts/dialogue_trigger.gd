extends Interaction

@export var dialogue_resource : DialogueResource
@export var dialogue_start := "start"
@export var BALLOON = preload("res://Objects/balloon.tscn")

var balloon = null

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended);


#region States
func activate() -> void:
	if active:
		print("Activating dialogue while it's already active!")

	balloon = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)

	active = true;


func update(player : Player) -> void:
	Debugger.printui("update interaction object: " + name)
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
	active = false
	if !repeat:
		queue_free()
#engregion
