extends Button

@onready var label : RichTextLabel = find_child("RichTextLabel")

func _ready() -> void:
	var action_keycode = Ge.get_action_keycode("stance")
	
	var filepath : String = "res://UI/Buttons/button_keyboard_" + action_keycode + ".png"
	if FileAccess.file_exists(filepath):
		label.text = "[img]" + filepath + "[/img]" + label.text


func _on_check_button_toggled(toggled_on: bool) -> void:
	Ge.show_tutorials = toggled_on
