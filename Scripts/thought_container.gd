extends VBoxContainer

var thought_scene = preload("res://Objects/thought.tscn")

func push(text: String) -> void:
	var text_found := false
	for child : RichTextLabel in get_children():
		if child.text == text:
			text_found = true
			child.tween_reset()
			break
	if !text_found:
		var thought = thought_scene.instantiate()
		add_child(thought)
		thought.text = text
