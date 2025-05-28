extends CheckButton


func _ready() -> void:
	print("name: "+str(name))
	match name:
		"Fullscreen":
			button_pressed = DisplayServer.window_get_mode()
		"PixelPerfect":
			button_pressed = get_window().get_content_scale_aspect() == Window.CONTENT_SCALE_ASPECT_KEEP
		"Borderless":
			button_pressed = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
