extends Node

var config_path := "user://options.cfg"

var fullscreen := false
var borderless := false
var pixel_perfect := false
var window_size := Vector2(1280, 720)
var window_pos := Vector2(0, 0)


func _ready() -> void:
	#region Setup display
	var screen_size : Vector2 = DisplayServer.screen_get_size()
	DisplayServer.window_set_size(window_size)
	#Load display
	if load_options() != OK:
		window_pos = (screen_size - window_size)/2
		window_pos.x += DisplayServer.screen_get_size().x;
	get_window().set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_KEEP if pixel_perfect else Window.CONTENT_SCALE_ASPECT_EXPAND)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true if borderless else false)
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_position(window_pos)
	#endregion

func save_options() -> void:
	var config = ConfigFile.new()
	config.set_value("window", "fullscreen", fullscreen)
	config.set_value("window", "borderless", borderless)
	config.set_value("window", "pixel_perfect", pixel_perfect)
	config.set_value("window", "window_pos", DisplayServer.window_get_position())
	config.save(config_path)
func load_options() -> int:
	var config = ConfigFile.new()
	var err = config.load(config_path)
	if err == OK:
		fullscreen		= config.get_value("window", "fullscreen", false)
		borderless 		= config.get_value("window", "borderless", borderless)
		pixel_perfect	= config.get_value("window", "pixel_perfect", pixel_perfect)
		window_pos		= config.get_value("window", "window_pos", window_pos)
		if window_pos == Vector2(0, 0):
			var screen_size : Vector2 = DisplayServer.screen_get_size()
			window_pos = (screen_size - window_size)/2
			window_pos.x += DisplayServer.screen_get_size().x;
	return err

func _notification(what: int) -> void:
	print("what: "+str(what))
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var pos = DisplayServer.window_get_position()
		save_options()
