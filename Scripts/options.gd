extends Node

var config_path := "user://options.ini"

var fullscreen := false
var borderless := false
var pixel_perfect := false
var window_size := Vector2(1280, 720)
var window_pos := Vector2(0, 0)
var window_screen := 0
var current_screen := 0
var hud_scale := 2
var shadow_intensity = 1.0
var adult_content_enabled := true

var master_volume := 1.0
var bgm_volume := 1.0
var amb_volume := 1.0
var sfx_volume := 1.0

func _set_window_position() -> void:
	DisplayServer.window_set_position(window_pos)

func _ready() -> void:
	#region Setup display
	#Load display
	var options_loaded = load_options()
	print("options_loaded: "+str(options_loaded == OK))
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
		DisplayServer.window_set_position((DisplayServer.screen_get_size() - DisplayServer.window_get_size())/2)
	#endregion

func _process(delta: float) -> void:
	# Update current display
	var screen := DisplayServer.window_get_current_screen()
	if screen != current_screen:
		print("Screen changed")
		current_screen = screen
		notification(NOTIFICATION_WM_SIZE_CHANGED)



func save_options() -> void:
	print("Save options")
	print_stack()
	var config := ConfigFile.new()
	if FileAccess.file_exists(config_path):
		config.load(config_path)

	config.set_value("Game", "version", OS.get_version())
	#region Save Display
	config.set_value("window", "fullscreen",	fullscreen)
	config.set_value("window", "borderless", 	borderless)
	config.set_value("window", "pixel_perfect", pixel_perfect)
	config.set_value("window", "window_pos",	DisplayServer.window_get_position())
	config.set_value("window", "window_size",	DisplayServer.window_get_size())
	config.set_value("window", "window_screen", DisplayServer.window_get_current_screen())
	#endregion
	#region Save Audio
	config.set_value("audio", "Master", master_volume)
	config.set_value("audio", "BGM", 	bgm_volume)
	config.set_value("audio", "AMB", 	amb_volume)
	config.set_value("audio", "SFX",	sfx_volume)
	#endregion
	#region Noise
	config.set_value("noise", "enabled",	Ge.noise_enabled)
	config.set_value("noise", "color",		Ge.noise_color)
	#endregion
	config.set_value("gameplay", "show_tutorials", Ge.show_tutorials)
	config.set_value("gameplay", "show_hints", Ge.show_hints)
	config.set_value("gameplay", "show_interaction_prompts", Ge.show_interaction_prompts)
	config.set_value("gameplay", "hud_scale", hud_scale)
	config.set_value("gameplay", "shadow_intensity", shadow_intensity)
	config.set_value("gameplay", "adult_content_enabled", adult_content_enabled)
	
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
		master_volume	= config.get_value("audio", "Master", 1.0)
		bgm_volume		= config.get_value("audio", "BGM", 1.0)
		amb_volume 		= config.get_value("audio", "AMB", 1.0)
		sfx_volume 		= config.get_value("audio", "SFX", 1.0)
		FmodServer.set_global_parameter_by_name("MASTER_VOLUME",	master_volume)
		FmodServer.set_global_parameter_by_name("BGM_VOLUME",		bgm_volume)
		FmodServer.set_global_parameter_by_name("AMB_VOLUME", 		amb_volume)
		FmodServer.set_global_parameter_by_name("SFX_VOLUME", 		sfx_volume)
		#endregion
		#region Noise
		Ge.noise_enabled	= config.get_value("noise", "enabled", false)
		Ge.noise_color		= config.get_value("noise", "color", false)
		#endregion
		#region Gameplay
		Ge.show_tutorials	= config.get_value("gameplay", "show_tutorials", true)
		Ge.show_hints		= config.get_value("gameplay", "show_hints", true)
		Ge.show_interaction_prompts	= config.get_value("gameplay", "show_interaction_prompts", true)
		hud_scale			= config.get_value("gameplay", "hud_scale", 1)
		shadow_intensity	= config.get_value("gameplay", "shadow_intensity", 1.0)
		adult_content_enabled	= config.get_value("gameplay", "adult_content_enabled", 1.0)
		#endregion
		#region Keybindings
		if config.has_section("keyboard"):
			var keys = config.get_section_keys("keyboard")
			#print("keys: "+str(keys))
			for key in keys:
				#print("key: "+str(key))
				var saved_input = config.get_value("keyboard", key)
				var ev := InputEventKey.new()
				ev.keycode = saved_input
				#print("saved_input: "+str(saved_input))
				if saved_input:
					InputMap.action_erase_events(key)
					InputMap.action_add_event(key, ev)
		#endregion
	else:
		pass
	return err

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		# Skip centering in fullscreen
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			return

		var screen			:= DisplayServer.window_get_current_screen()
		var _window_size	:= DisplayServer.window_get_size()
		var display_size	:= DisplayServer.screen_get_size(screen)
		print("screen: "+str(screen))
		print("window_size: "+str(_window_size))
		print("display_size: "+str(display_size))

		DisplayServer.window_set_position((display_size - _window_size) / 2)
		DisplayServer.window_set_current_screen(screen)
