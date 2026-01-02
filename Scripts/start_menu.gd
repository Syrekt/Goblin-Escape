class_name StartMenu extends CanvasLayer


var ingame_menu = preload("res://UI/ingame_menu.tscn")
var ingame_menu_inst : IngameMenu = null

func _ready() -> void:
	if OS.is_debug_build():
		queue_free()

func _on_start_game_pressed() -> void:
	queue_free()

func _on_options_pressed() -> void:
	ingame_menu_inst = ingame_menu.instantiate()
	add_child(ingame_menu_inst)
	ingame_menu_inst.close_button.pressed.connect(_on_ingame_menu_close_button_pressed)
	hide()


func _on_steam_pressed() -> void:
	OS.shell_open("https://store.steampowered.com/developer/psychoseel")


func _on_itch_pressed() -> void:
	OS.shell_open("https://psychoseel.itch.io/")


func _on_discord_pressed() -> void:
	OS.shell_open("https://discord.gg/e28ByRr")


func _on_exit_pressed() -> void:
	get_tree().quit()



func _on_ingame_menu_close_button_pressed() -> void:
	show()
