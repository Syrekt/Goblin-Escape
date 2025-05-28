extends TabContainer


@onready var resolution : OptionButton = find_child("Resolution")


func _ready() -> void:
	get_tree().paused = true
	var screen_size : Vector2 = DisplayServer.screen_get_size()
	match screen_size:
		Vector2(1280, 720):
			resolution.index = 0
		Vector2(1920, 1080):
			resolution.index = 1

func _exit_tree() -> void:
	get_tree().paused = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_option_button_item_selected(index: int) -> void:
	print("index: "+str(index))
	var screen_size : Vector2 = DisplayServer.screen_get_size()
	var new_size : Vector2
	match index:
		0:
			new_size = Vector2(1280, 720)
		1:
			new_size = Vector2i(1920, 1080)
		2:
			new_size = Vector2i(1920, 1080)

	DisplayServer.window_set_size(new_size)
	DisplayServer.window_set_position((screen_size - new_size)/2)

func _on_pixel_perfect_toggled(toggled_on: bool) -> void:
	var window : Window = get_window()
	window.set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_KEEP if toggled_on else Window.CONTENT_SCALE_ASPECT_EXPAND)


func _on_borderless_toggled(toggled_on:bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true if toggled_on else false)
