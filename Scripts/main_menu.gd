extends Control


var confirmation_dialogue = preload("res://Scenes/confirmation_dialog.tscn")

@onready var vbox = $VBoxContainer
@onready var options = $OptionsMenu

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_start_game_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	queue_free()


func _on_options_pressed() -> void:
	options.visible = !options.visible

func _on_exit_game_pressed() -> void:
	var _confirmation_dialogue = confirmation_dialogue.instantiate()
	add_child(_confirmation_dialogue)
	var label_path = "Control/ItemList/PanelContainer/Label"

	_confirmation_dialogue.get_node(label_path).text = "Are you sure you want to quit?"
	_confirmation_dialogue.confirmation_function	= func() -> void: get_tree().quit()
	_confirmation_dialogue.rejection_function		= func() -> void: _confirmation_dialogue.queue_free()


func _on_option_button_item_selected(index: int) -> void:
	print("index: "+str(index))
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		1:
			DisplayServer.window_set_size(Vector2i(1920, 1080))


func _on_check_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
