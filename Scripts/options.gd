extends Node

var config_path := "user://options.cfg"

var fullscreen := false
var borderless := false
var pixel_perfect := false
var window_size := Vector2(1280, 720)
var window_pos := Vector2(0, 0)
var window_screen := 0
var current_screen := 0

func _set_window_position() -> void:
	DisplayServer.window_set_position(window_pos)

func _ready() -> void:
	#region Setup display
	#Load display
	var options_loaded = load_options()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)
	DisplayServer.window_set_size(window_size)
	DisplayServer.window_set_current_screen(window_screen)
	DisplayServer.window_set_position(window_pos)


	if pixel_perfect:
		get_window().set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_KEEP)
	else:
		get_window().set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_EXPAND)
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if options_loaded != OK:
		notification(NOTIFICATION_WM_SIZE_CHANGED)
	#endregion


func save_options() -> void:
	var config = ConfigFile.new()
	config.set_value("window", "fullscreen",	fullscreen)
	config.set_value("window", "borderless", 	borderless)
	config.set_value("window", "pixel_perfect", pixel_perfect)
	config.set_value("window", "window_pos",	DisplayServer.window_get_position())
	config.set_value("window", "window_size",	DisplayServer.window_get_size())
	config.set_value("window", "window_screen", DisplayServer.window_get_current_screen())
	config.set_value("audio", "Master", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	config.set_value("audio", "SFX",	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	config.set_value("audio", "EFX", 	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("EFX")))
	config.set_value("audio", "BGM", 	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM")))
	config.set_value("noise", "enabled",	Ge.noise_enabled)
	config.set_value("noise", "color",		Ge.noise_color)
	config.save(config_path)
func load_options() -> int:
	var config = ConfigFile.new()
	var err = config.load(config_path)
	if err == OK:
		#region Load Display
		fullscreen		= config.get_value("window", "fullscreen", false)
		borderless 		= config.get_value("window", "borderless", borderless)
		pixel_perfect	= config.get_value("window", "pixel_perfect", pixel_perfect)
		window_pos		= config.get_value("window", "window_pos", window_pos)
		window_size		= config.get_value("window", "window_size", window_size)
		window_screen   = config.get_value("window", "window_screen", window_screen)
		print("window_pos: "+str(window_pos))
		print("window_size: "+str(window_size))
		print("window_screen: "+str(window_screen))
		#endregion
		#region Load Audio
		var master_bus	= [AudioServer.get_bus_index("Master"), config.get_value("audio", "Master", 0)]
		var sfx_bus		= [AudioServer.get_bus_index("SFX"), config.get_value("audio", "SFX", 0)]
		var efx_bus		= [AudioServer.get_bus_index("EFX"), config.get_value("audio", "EFX", 0)]
		var bgm_bus		= [AudioServer.get_bus_index("BGM"), config.get_value("audio", "BGM", 0)]
		AudioServer.set_bus_volume_db(master_bus[0], master_bus[1])
		AudioServer.set_bus_volume_db(sfx_bus[0], sfx_bus[1])
		AudioServer.set_bus_volume_db(efx_bus[0], efx_bus[1])
		AudioServer.set_bus_volume_db(bgm_bus[0], bgm_bus[1])
		AudioServer.set_bus_mute(master_bus[0], master_bus[1] <= -10.0)
		AudioServer.set_bus_mute(sfx_bus[0], sfx_bus[1] <= -10.0)
		AudioServer.set_bus_mute(efx_bus[0], efx_bus[1] <= -10.0)
		AudioServer.set_bus_mute(bgm_bus[0], bgm_bus[1] <= -10.0)
		#endregion
		#region Noise
		Ge.noise_enabled	= config.get_value("noise", "enabled", false)
		Ge.noise_color		= config.get_value("noise", "color", false)
		#endregion
	return err

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Save options")
		save_options()
	if what == NOTIFICATION_WM_POSITION_CHANGED:
		save_options()
