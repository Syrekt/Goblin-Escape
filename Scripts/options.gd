extends Node

var config_path := "user://options.ini"

var fullscreen				:= false
var borderless 				:= false
var pixel_perfect			:= true
var window_size				:= Vector2(1280, 720)
var window_pos				:= Vector2(0, 0)
var window_screen			:= 0
var current_screen			:= 0
var hud_scale				:= 2
var shadow_intensity		:= 1.0
var adult_content_enabled	:= true
var adult_build				:= OS.has_feature("nsfw") || OS.is_debug_build()
var combat_assist			:= false
enum DIFFICULTY {EASY, NORMAL, BRUTAL}
var difficulty				:= DIFFICULTY.NORMAL
var collect_analytics		:= true
var found_analytics_option_save_data := false

var master_volume := 0.5:
	set(value):
		FmodServer.set_global_parameter_by_name("MASTER_VOLUME", value)
		master_volume = value
var bgm_volume := 1.0:
	set(value):
		FmodServer.set_global_parameter_by_name("BGM_VOLUME", value)
		bgm_volume = value
var amb_volume := 1.0:
	set(value):
		FmodServer.set_global_parameter_by_name("AMB_VOLUME", value)
		amb_volume = value
var sfx_volume := 1.0:
	set(value):
		FmodServer.set_global_parameter_by_name("SFX_VOLUME", value)
		sfx_volume = value
var screenshake_enabled := true
var disable_low_health_effects_on_sex := false

var update_available	: bool
var update_link			: String
var update_site_name	:= "Patreon"

func _set_window_position() -> void:
	DisplayServer.window_set_position(window_pos)

func _ready() -> void:
	# Adult Content
	if !adult_build:
		adult_content_enabled = false
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

	Talo.players.identify("anonymous", OS.get_unique_id())
	Talo.game_config.live_config_loaded.connect(_on_live_config_loaded)
	Talo.game_config.get_live_config()

func _on_live_config_loaded(config: TaloLiveConfig) -> void:
	var latest_version = config.get_prop("Latest Version", "Unkown")
	update_available = latest_version != ProjectSettings.get_setting("application/config/version")
	update_link = config.get_prop("Last Version Link", "https://www.patreon.com/posts/goblin-escape-v0-149221995")
	update_site_name = config.get_prop("Update Site Name", "Patreon")

func _process(delta: float) -> void:
	# Update current display
	var screen := DisplayServer.window_get_current_screen()
	if screen != current_screen:
		print("Screen changed")
		current_screen = screen
		notification(NOTIFICATION_WM_SIZE_CHANGED)
		save_options()




#region Save Options
func save_options() -> void:
	print("Save options")
	print_stack()
	var config := ConfigFile.new()
	if FileAccess.file_exists(config_path):
		config.load(config_path)

	config.set_value("Game", "version", OS.get_version())
	#region Save Display
	config.set_value("display", "fullscreen",	fullscreen)
	config.set_value("display", "borderless", 	borderless)
	config.set_value("display", "pixel_perfect", pixel_perfect)
	config.set_value("display", "window_pos",	DisplayServer.window_get_position())
	config.set_value("display", "window_size",	DisplayServer.window_get_size())
	config.set_value("display", "window_screen", DisplayServer.window_get_current_screen())
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
	#region Gameplay
	config.set_value("gameplay", "show_tutorials", Ge.show_tutorials)
	config.set_value("gameplay", "show_hints", Ge.show_hints)
	config.set_value("gameplay", "show_interaction_prompts", Ge.show_interaction_prompts)
	config.set_value("gameplay", "hud_scale", hud_scale)
	config.set_value("gameplay", "shadow_intensity", shadow_intensity)
	if adult_build:
		config.set_value("gameplay", "adult_content_enabled", adult_content_enabled)
	config.set_value("gameplay", "screenshake_enabled", screenshake_enabled)
	config.set_value("gameplay", "disable_low_health_fx_on_sex", disable_low_health_effects_on_sex)
	config.set_value("gameplay", "combat_assist", combat_assist)
	config.set_value("gameplay", "difficulty", difficulty)
	config.set_value("gameplay", "collect_analytics", collect_analytics)
	#endregion
	Talo.events.track("Settings saved", {
		"fullscreen"			: str(fullscreen),
		"borderless"			: str(borderless),
		"pixel_perfect"			: str(pixel_perfect),
		"window_size"			: str(window_size),
		"window_pos"			: str(window_pos),
		"window_screen"			: str(window_screen),
		"current_screen"		: str(current_screen),
		"hud_scale"				: str(hud_scale),
		"shadow_intensity"		: str(shadow_intensity),
		"adult_content_enabled"	: str(adult_content_enabled),
		"adult_build"			: str(adult_build),
		"combat_assist"			: str(combat_assist),
		"difficulty"			: str(difficulty),
		"collect_analytics"		: str(collect_analytics),
	})
	
	if config.has_section("window"):
		config.erase_section("window")
	config.save(config_path)
#endregion
#region Load Options
func load_options() -> int:
	var config = ConfigFile.new()
	var err = config.load(config_path)
	if err == OK:
		#region Load Display
		fullscreen		= config.get_value("display", "fullscreen", false)
		borderless 		= config.get_value("display", "borderless", borderless)
		pixel_perfect	= config.get_value("display", "pixel_perfect", pixel_perfect)
		window_pos		= config.get_value("display", "window_pos", window_pos)
		window_size		= config.get_value("display", "window_size", window_size)
		window_screen   = config.get_value("display", "window_screen", window_screen)
		print("window_pos: "+str(window_pos))
		print("window_size: "+str(window_size))
		print("window_screen: "+str(window_screen))
		#endregion
		#region Load Audio
		master_volume	= config.get_value("audio", "Master", 0.5)
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
		Ge.show_tutorials					= config.get_value("gameplay", "show_tutorials", true)
		Ge.show_hints						= config.get_value("gameplay", "show_hints", true)
		Ge.show_interaction_prompts			= config.get_value("gameplay", "show_interaction_prompts", true)
		hud_scale							= config.get_value("gameplay", "hud_scale", 1)
		shadow_intensity					= config.get_value("gameplay", "shadow_intensity", 1.0)
		if adult_build:
			adult_content_enabled = config.get_value("gameplay", "adult_content_enabled", 1.0)
		else:
			adult_content_enabled = false
		screenshake_enabled					= config.get_value("gameplay", "screenshake_enabled", 1.0)
		disable_low_health_effects_on_sex	= config.get_value("gameplay", "disable_low_health_effects_on_sex", 1.0)
		combat_assist						= config.get_value("gameplay", "combat_assist", false)
		difficulty							= config.get_value("gameplay", "difficulty", DIFFICULTY.NORMAL)
		if config.has_section_key("gameplay", "collect_analytics"):
			found_analytics_option_save_data = true
		collect_analytics					= config.get_value("gameplay", "collect_analytics", collect_analytics)
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
		FmodServer.set_global_parameter_by_name("MASTER_VOLUME", master_volume)
	return err
#endregion

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
