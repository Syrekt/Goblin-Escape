extends RichTextLabel

func _ready() -> void:
	var action_keycode_path = Ge.get_action_keycode(owner.next_action, true)
	print("action_keycode: "+str(action_keycode_path))
	text = "[img]" + action_keycode_path + "[/img]" + text
