extends Button

@onready var label : RichTextLabel = find_child("RichTextLabel")

func _ready() -> void:
	var action_keycode = Ge.get_action_keycode("stance")
	if Ge.last_input_type == "keyboard":
		var filepath : String = "res://UI/Buttons/button_keyboard_" + action_keycode + ".png"
		if FileAccess.file_exists(filepath):
			label.text = "[img]" + filepath + "[/img]" + label.text
		else:
			print("File doesn't exists %s" % filepath)
	elif Ge.last_input_type == "gamepad":
		var filepath : String = "res://UI/Buttons/buttons_xbox" + action_keycode + ".png"
		if FileAccess.file_exists(filepath):
			label.text = "[img]" + filepath + "[/img]" + label.text
		else:
			print("File doesn't exists %s" % filepath)


func _on_check_button_toggled(toggled_on: bool) -> void:
	Ge.show_tutorials = toggled_on

#func _draw() -> void:
#	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0, 0, 1))
