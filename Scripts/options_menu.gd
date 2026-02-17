extends TabContainer


@onready var resolution : OptionButton = find_child("Resolution")

@onready var noise_color_r : HSlider = find_child("NoiseColorRedSlider")
@onready var noise_color_g : HSlider = find_child("NoiseColorGreenSlider")
@onready var noise_color_b : HSlider = find_child("NoiseColorBlueSlider")
@onready var noise_color_a : HSlider = find_child("NoiseColorAlphaSlider")

@onready var noise_toggle : CheckBox = find_child("NoiseToggleCheckButton")
@onready var borderless_toggle : CheckBox = find_child("Borderless")
@onready var fullscreen_toggle : CheckBox = find_child("Fullscreen")

@onready var slider_red_label : Label = find_child("Red").find_child("Label")
@onready var slider_green_label : Label = find_child("Green").find_child("Label")
@onready var slider_blue_label : Label = find_child("Blue").find_child("Label")
@onready var slider_alpha_label : Label = find_child("Alpha").find_child("Label")

@onready var noise_color_rect : ColorRect = find_child("NoiseColorRect")

@onready var reset_keybindings : Button = find_child("ResetKeybindings")

@onready var master_bus_id			:= AudioServer.get_bus_index("Master")
@onready var sfx_bus_id				:= AudioServer.get_bus_index("SFX")
@onready var amb_bus_id 			:= AudioServer.get_bus_index("AMB")
@onready var bgm_bus_id 			:= AudioServer.get_bus_index("BGM")
@onready var master_volume_slider	: HSlider = find_child("MasterVolume")
@onready var sfx_volume_slider		: HSlider = find_child("SFXVolume")
@onready var amb_volume_slider 		: HSlider = find_child("AMBVolume")
@onready var bgm_volume_slider 		: HSlider = find_child("BGMVolume")

@onready var combat_assist_toggle		: CheckBox = find_child("CombatAssist")
@onready var tutorial_toggle			: CheckBox = find_child("ShowTutorials")
@onready var hint_toggle				: CheckBox = find_child("ShowHints")
@onready var interaction_prompts_toggle	: CheckBox = find_child("ShowInteractionPrompts")
@onready var hud_scale_option			: OptionButton = find_child("HudScaleOption")
@onready var shadow_intensity_slider	: HSlider = find_child("ShadowIntensity")
@onready var adult_content_toggle		: CheckBox = find_child("AdultContent")
@onready var screenshake_toggle			: CheckBox = find_child("Screenshake")
@onready var low_health_fx				: CheckBox = find_child("LowHealthFX")
@onready var difficulty_option			: OptionButton = find_child("Difficulty")
@onready var analytics_toggle			: CheckBox = find_child("Analytics")

@onready var gamepad_layout: TextureRect = find_child("GamepadLayout")


var open_tutorial : CanvasLayer

var default_keybindings : Dictionary = {
	"up"		: [KEY_W],
	"down"		: [KEY_S],
	"left" 		: [KEY_A],
	"right"		: [KEY_D],
	"attack"	: [KEY_J],
	"stance" 	: [KEY_SPACE],
	"jump"		: [KEY_K],
	"sprint"	: [KEY_SHIFT],
	"walk"		: [KEY_CTRL],
	"interact"	: [KEY_E],
	"inventory"	: [KEY_I],
}


func _ready() -> void:
	print("options menu ready")
	current_tab = 0
	get_tree().paused = true
	$Graphics.grab_focus()
	var screen_size : Vector2 = DisplayServer.window_get_size()
	match screen_size:
		Vector2(640, 360):
			resolution.selected = 0
		Vector2(1280, 720):
			resolution.selected = 1
		Vector2(1920, 1080):
			resolution.selected = 2
		Vector2(2560, 1440):
			resolution.selected = 3

	noise_color_r.value = Ge.noise_color.r * 255.0
	noise_color_g.value = Ge.noise_color.g * 255.0
	noise_color_b.value = Ge.noise_color.b * 255.0
	noise_color_a.value = Ge.noise_color.a * 255.0

	noise_toggle.set_pressed_no_signal(Ge.noise_enabled)
	borderless_toggle.set_pressed_no_signal(Options.borderless)

	master_volume_slider.value	= FmodServer.get_global_parameter_by_name("MASTER_VOLUME")
	bgm_volume_slider.value		= FmodServer.get_global_parameter_by_name("BGM_VOLUME")
	amb_volume_slider.value		= FmodServer.get_global_parameter_by_name("AMB_VOLUME")
	sfx_volume_slider.value		= FmodServer.get_global_parameter_by_name("SFX_VOLUME")

	combat_assist_toggle.set_pressed_no_signal(Options.combat_assist)
	tutorial_toggle.set_pressed_no_signal(Ge.show_tutorials)
	hint_toggle.set_pressed_no_signal(Ge.show_hints)
	interaction_prompts_toggle.set_pressed_no_signal(Ge.show_interaction_prompts)

	var hud_scale = Options.hud_scale
	match hud_scale:
		1:
			hud_scale_option.selected = 0
		2:
			hud_scale_option.selected = 1

	var shadow_intensity = Options.shadow_intensity
	shadow_intensity_slider.value = shadow_intensity

	screenshake_toggle.set_pressed_no_signal(Options.screenshake_enabled)

	# Adult Content
	if !Options.adult_build:
		adult_content_toggle.get_parent().queue_free()
		low_health_fx.get_parent().queue_free()
	else:
		adult_content_toggle.set_pressed_no_signal(Options.adult_content_enabled)
		low_health_fx.set_pressed_no_signal(Options.disable_low_health_effects_on_sex)

	var difficulty = Options.difficulty
	difficulty_option.selected = difficulty
	var collect_analytics = Options.collect_analytics
	analytics_toggle.set_pressed_no_signal(collect_analytics)


func _process(delta: float) -> void:
	resolution.disabled			= Options.fullscreen
	borderless_toggle.disabled	= Options.fullscreen
	

	noise_color_rect.color = Color(noise_color_r.value/255.0, noise_color_g.value/255.0, noise_color_b.value/255.0, noise_color_a.value/255.0)

	slider_red_label.text	= "Red: " + str(int(noise_color_r.value))
	slider_green_label.text = "Green: " + str(int(noise_color_g.value))
	slider_blue_label.text	= "Blue: " + str(int(noise_color_b.value))
	slider_alpha_label.text	= "Alpha: " + str(int(noise_color_a.value))

	if Input.is_action_just_pressed("ui_focus_prev"):
		select_previous_available()
		get_tab_control(current_tab).grab_focus()
	elif Input.is_action_just_pressed("ui_focus_next"):
		select_next_available()
		get_tab_control(current_tab).grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if gamepad_layout.visible:
		gamepad_layout.hide()
		var vbox1 = $Controls/MarginContainer/HSplitContainer/VBoxContainer
		var vbox2 = $Controls/MarginContainer/HSplitContainer/VBoxContainer2
		vbox1.show()
		vbox2.show()


func _exit_tree() -> void:
	Options.save_options()
	get_tree().paused = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		# Skip centering in fullscreen
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			return

		var screen			:= DisplayServer.window_get_current_screen()
		var window_size		:= DisplayServer.window_get_size()
		var display_size	:= DisplayServer.screen_get_size(screen)
		print("screen: "+str(screen))
		print("window_size: "+str(window_size))
		print("display_size: "+str(display_size))

		DisplayServer.window_set_position((display_size - window_size) / 2)
		DisplayServer.window_set_current_screen(screen)
#region Signals
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_on_borderless_toggled(false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		_on_borderless_toggled(false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_on_borderless_toggled(Options.borderless)
	Options.fullscreen = toggled_on
	print("Options.fullscreen: "+str(Options.fullscreen));
	notification(NOTIFICATION_WM_SIZE_CHANGED)

func _on_option_button_item_selected(index: int) -> void:
	var new_size : Vector2
	match index:
		0:
			new_size = Vector2(640, 360)
		1:
			new_size = Vector2(1280, 720)
		2:
			new_size = Vector2i(1920, 1080)
		3:
			new_size = Vector2i(2560, 1440)

	print("Update resolution")
	DisplayServer.window_set_size(new_size)
	Options.window_size = new_size
	print("Options.window_size: "+str(Options.window_size));
	notification(NOTIFICATION_WM_SIZE_CHANGED)

func _on_pixel_perfect_toggled(toggled_on: bool) -> void:
	var window : Window = get_window()
	window.set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_KEEP if toggled_on else Window.CONTENT_SCALE_ASPECT_EXPAND)
	Options.pixel_perfect = toggled_on


func _on_borderless_toggled(toggled_on: bool) -> void:
	print("toggle borderless")
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true if toggled_on else false)
	Options.borderless = toggled_on
	DisplayServer.window_set_size(Options.window_size)

func _on_noise_color_color_changed(color: Color) -> void:
	Ge.noise_color = color


func _on_reset_color_pressed() -> void:
	Ge.noise_color = Color(1, 1, 1, 0.2)
	noise_color_r.value = Ge.noise_color.r * 255.0
	noise_color_g.value = Ge.noise_color.g * 255.0
	noise_color_b.value = Ge.noise_color.b * 255.0
	noise_color_a.value = Ge.noise_color.a * 255.0


func _on_center_window_pressed() -> void:
	notification(NOTIFICATION_WM_SIZE_CHANGED)


func _on_noise_color_red_slider_drag_ended(value_changed: bool) -> void:
	Ge.noise_color.r = noise_color_r.value / 255.0
func _on_noise_color_red_slider_value_changed(value: float) -> void:
	Ge.noise_color.r = value / 255.0

func _on_noise_color_green_slider_drag_ended(value_changed: bool) -> void:
	Ge.noise_color.g = noise_color_g.value / 255.0
func _on_noise_color_green_slider_value_changed(value: float) -> void:
	Ge.noise_color.g = value / 255.0

func _on_noise_color_blue_slider_drag_ended(value_changed: bool) -> void:
	print("noise_color_b.value: "+str(noise_color_b.value));
	Ge.noise_color.b = noise_color_b.value / 255.0
func _on_noise_color_blue_slider_value_changed(value: float) -> void:
	Ge.noise_color.b = value / 255.0


func _on_noise_color_alpha_slider_drag_ended(value_changed: bool) -> void:
	Ge.noise_color.a = noise_color_a.value / 255.0
func _on_noise_color_alpha_slider_value_changed(value: float) -> void:
	Ge.noise_color.a = value / 255.0


func _on_check_button_toggled(toggled_on: bool) -> void:
	Ge.noise_enabled = toggled_on


func _on_reset_keybindings_pressed() -> void:
	print("Reset keybindings")
	# Re-add defaults
	for action in default_keybindings.keys():
		InputMap.action_erase_events(action)
		for key in default_keybindings[action]:
			var ev := InputEventKey.new()
			ev.keycode = key
			print("key: "+str(key))
			print("ev: "+str(ev))
			InputMap.action_add_event(action, ev)
	for button in get_tree().get_nodes_in_group("key_bind_buttons"):
		button.set_text_for_key()


func _on_master_volume_value_changed(value: float) -> void:
	Options.master_volume = value
func _on_bgm_volume_value_changed(value: float) -> void:
	Options.bgm_volume = value
func _on_amb_volume_value_changed(value: float) -> void:
	Options.amb_volume = value
func _on_sfx_volume_value_changed(value: float) -> void:
	Options.sfx_volume = value

func _on_show_tutorials_toggled(toggled_on: bool) -> void:
	Ge.show_tutorials = toggled_on

func _on_show_hints_toggled(toggled_on: bool) -> void:
	Ge.show_hints = toggled_on

func _on_show_interaction_prompts_toggled(toggled_on: bool) -> void:
	Ge.show_interaction_prompts = toggled_on

func _on_hud_scale_option_item_selected(index: int) -> void:
	match index:
		0:
			Options.hud_scale = 1
		1:
			Options.hud_scale = 2

func _on_shadow_intensity_drag_ended(value_changed: bool) -> void:
	Options.shadow_intensity = shadow_intensity_slider.value

func _on_adult_content_toggled(toggled_on: bool) -> void:
	Options.adult_content_enabled = toggled_on

func _on_tutorial_button_pressed(tutorial_scene:PackedScene) -> void:
	print("Show combat tutorial")
	open_tutorial = tutorial_scene.instantiate()
	open_tutorial.from_options_menu = true
	open_tutorial.layer = 2
	add_child(open_tutorial)

func _on_switch_monitor_pressed() -> void:
	var display_count = DisplayServer.get_screen_count()
	print("display_count: "+str(display_count))
	var current_screen = DisplayServer.window_get_current_screen()
	print("current_screen: "+str(current_screen))
	DisplayServer.window_set_current_screen((current_screen + 1) % display_count)
	notification(NOTIFICATION_WM_SIZE_CHANGED)

func _on_screenshake_toggled(toggled_on: bool) -> void:
	Options.screenshake_enabled = toggled_on


func _on_reset_save_pressed() -> void:
	$Gameplay/MarginContainer/VBoxContainer/ResetSave/ResetSaveConfirmation.show()


func _on_low_health_fx_toggled(toggled_on: bool) -> void:
	Options.disable_low_health_effects_on_sex = toggled_on

func _on_reset_graphics_pressed() -> void:
	if FileAccess.file_exists(Options.config_path):
		var config := ConfigFile.new()
		var err = config.load(Options.config_path)
		if err == OK:
			if config.has_section("display"):
				config.erase_section("display")
			config.save(Options.config_path)
		get_tree().quit()

func _on_reset_audio_pressed() -> void:
	if FileAccess.file_exists(Options.config_path):
		var config := ConfigFile.new()
		var err = config.load(Options.config_path)
		if err == OK:
			if config.has_section("audio"):
				config.erase_section("audio")
			config.save(Options.config_path)
	Options.master_volume = 0.5
	Options.bgm_volume = 1.0
	Options.amb_volume = 1.0
	Options.sfx_volume = 1.0
	queue_free()

func _on_combat_assist_toggled(toggled_on: bool) -> void:
	Options.combat_assist = toggled_on
func _on_difficulty_item_selected(index: int) -> void:
	match index:
		0:
			Options.difficulty = Options.DIFFICULTY.EASY
		1:
			Options.difficulty = Options.DIFFICULTY.NORMAL
		2:
			Options.difficulty = Options.DIFFICULTY.BRUTAL
func _on_analytics_toggled(toggled_on: bool) -> void:
	Options.collect_analytics = toggled_on
	if Options.collect_analytics:
		Talo.players.identify("anonymous", OS.get_unique_id())
	else:
		Talo.players.clear_identity()
#endregion


func _on_gamepad_bindings_pressed() -> void:
	gamepad_layout.show()
	var vbox1 = $Controls/MarginContainer/HSplitContainer/VBoxContainer
	var vbox2 = $Controls/MarginContainer/HSplitContainer/VBoxContainer2
	vbox1.hide()
	vbox2.hide()
