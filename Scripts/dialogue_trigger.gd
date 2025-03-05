extends Area2D

@export var dialogue_resource : DialogueResource
@export var dialogue_start := "start"

var active = false

func action() -> void:
	if !active:
		active = true;
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
