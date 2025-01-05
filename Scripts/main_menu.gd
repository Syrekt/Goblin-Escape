extends Control


var confirmation_dialogue = preload("res://Scenes/confirmation_dialog.tscn")
var options_menu = preload("res://UI/options_menu.tscn")

@onready var vbox = $VBoxContainer
@onready var options = $OptionsMenu

func _ready() -> void:
	call_deferred("grab_focus")


func _process(delta: float) -> void:
	pass


func _on_start_game_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_options_pressed() -> void:
	options.visible = !options.visible

func _on_exit_game_pressed() -> void:
	var _confirmation_dialogue = confirmation_dialogue.instantiate()
	add_child(_confirmation_dialogue)
	var label_path = "Control/ItemList/PanelContainer/Label"

	_confirmation_dialogue.get_node(label_path).text = "Are you sure you want to quit?"
	_confirmation_dialogue.confirmation_function	= func() -> void: get_tree().quit()
	_confirmation_dialogue.rejection_function		= func() -> void: _confirmation_dialogue.queue_free()
