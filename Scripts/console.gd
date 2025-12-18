extends CanvasLayer

@onready var console_input	: LineEdit = find_child("ConsoleInput")
@onready var console_output : RichTextLabel = find_child("ConsoleOutput")

var submitted_text : String ## Text comes from input
var history : Array[String]
var history_index := -1


func _ready() -> void:
	console_input.caret_blink = true
	console_input.keep_editing_on_text_submit = true
	console_output.scroll_following = true


func _on_visibility_changed() -> void:
	console_input.grab_focus()


func _on_console_input_text_submitted(new_text: String) -> void:
	submitted_text = new_text
	print("submitted_text: "+str(submitted_text))

	history.append(new_text)
	history_index = history.size()

	console_output.text += "\n" + new_text
	console_input.text = ""


func _on_console_input_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_QUOTELEFT:
				hide()
			KEY_UP:
				if history_index > 0:
					history_index -= 1
					console_input.text = history[history_index]
					console_input.caret_column = console_input.text.length()

			KEY_DOWN:
				if history_index < history.size() - 1:
					history_index += 1
					console_input.text = history[history_index]
					console_input.caret_column = console_input.text.length()
				else:
					history_index = history.size()
					console_input.clear()
