extends CheckBox


func _ready() -> void:
	print("Toggle button name: "+str(name))
	match name:
		"Fullscreen":
			set_pressed_no_signal(DisplayServer.window_get_mode())
		"PixelPerfect":
			set_pressed_no_signal(get_window().get_content_scale_aspect() == Window.CONTENT_SCALE_ASPECT_KEEP)
		"Borderless":
			set_pressed_no_signal(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
