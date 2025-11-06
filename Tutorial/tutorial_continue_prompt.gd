extends Button

@onready var label : RichTextLabel = find_child("RichTextLabel")

func _ready() -> void:
	var action_events = InputMap.action_get_events("stance")
	var action_event = action_events[0]
	print("action_event: "+str(action_event.physical_keycode))
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	print("action_keycode: "+str(action_keycode))
	
	var filepath : String = "res://UI/Buttons/button_keyboard_" + action_keycode + ".png"
	if FileAccess.file_exists(filepath):
		label.text = "[img]" + filepath + "[/img]" + label.text


func _on_check_button_toggled(toggled_on: bool) -> void:
	Ge.show_tutorials = toggled_on
