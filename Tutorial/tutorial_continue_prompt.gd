extends Button

@onready var label : RichTextLabel = find_child("RichTextLabel")

func _ready() -> void:
	var action_keycode = Ge.get_action_keycode("ui_cancel")
	print("action_keycode: "+str(action_keycode))
	var _icon = Ge.get_action_keycode("ui_cancel", true)
	if _icon != "":
		label.text = "[img]" + _icon + "[/img]" + label.text


func _on_check_button_toggled(toggled_on: bool) -> void:
	Ge.show_tutorials = toggled_on

#func _draw() -> void:
#	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0, 0, 1))
