extends Interaction


@export var BALLOON = preload("res://Objects/balloon.tscn")
@export_multiline var text : String
var dialogue_resource : DialogueResource

var balloon = null

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended);
	dialogue_resource = DialogueManager.create_resource_from_text("~ title\n" + text)

	if Game.get_singleton().get_data_in_room(name):
		queue_free()

#region Methods
func activate() -> void:
	if active:
		print("Activating dialogue while it's already active!")

	balloon = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, "title")

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
			Game.get_singleton().save_data_in_room(name, {"destroyed": true})
			queue_free()
#engregion
