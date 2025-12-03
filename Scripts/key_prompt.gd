class_name InputPrompt extends Area2D

@export_multiline var text : String

@onready var label : RichTextLabel = $RichTextLabel
var text_tween : Tween


func _on_body_entered(body: Node2D) -> void:
	update_input()
	if text_tween:
		text_tween.kill()
	text_tween = create_tween().bind_node(self)
	text_tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _on_body_exited(body: Node2D) -> void:
	if text_tween:
		text_tween.kill()
	text_tween = create_tween().bind_node(self)
	text_tween.tween_property(self, "modulate:a", 0.0, 1.0)

func update_input() -> void:
	var array = text.split(",")
	var icon_string := ""
	for action : String in array:
		print("action: "+str(action))
		if Ge.last_input_type == "keyboard":
			var action_keycode = Ge.get_action_keycode(action)
			icon_string += "[img]res://UI/Buttons/button_keyboard_" + action_keycode + ".png[/img]"
		elif Ge.last_input_type == "gamepad":
			var gamepad_button_index = Ge.get_action_keycode(action)
			icon_string += "[img]res://UI/Buttons/buttons_xbox" + gamepad_button_index + ".png[/img]"



	label.text = icon_string
