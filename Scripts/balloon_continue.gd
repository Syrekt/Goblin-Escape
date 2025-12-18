extends RichTextLabel

func _ready() -> void:
	var action_keycode = Ge.get_action_keycode(owner.next_action)
	print("action_keycode: "+str(action_keycode))
	if Ge.last_input_type == "keyboard":
		var filepath : String = "res://UI/Buttons/button_keyboard_" + action_keycode + ".png"
		if FileAccess.file_exists(filepath):
			text = "[img]" + filepath + "[/img]" + text
		else:
			print("File doesn't exists %s" % filepath)
	elif Ge.last_input_type == "gamepad":
		var filepath : String = "res://UI/Buttons/buttons_xbox" + action_keycode + ".png"
		if FileAccess.file_exists(filepath):
			text = "[img]" + filepath + "[/img]" + text
		else:
			print("File doesn't exists %s" % filepath)
