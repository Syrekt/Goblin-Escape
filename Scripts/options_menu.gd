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

@onready var master_bus_id	:= AudioServer.get_bus_index("Master")
@onready var sfx_bus_id		:= AudioServer.get_bus_index("SFX")
@onready var efx_bus_id 	:= AudioServer.get_bus_index("EFX")
@onready var bgm_bus_id 	:= AudioServer.get_bus_index("BGM")
@onready var master_volume_slider	: HSlider = find_child("MasterVolume")
@onready var sfx_volume_slider		: HSlider = find_child("SFXVolume")
@onready var efx_volume_slider 		: HSlider = find_child("EFXVolume")
@onready var bgm_volume_slider 		: HSlider = find_child("BGMVolume")

@onready var tutorial_toggle	: CheckBox = find_child("ShowTutorials")
@onready var hint_toggle		: CheckBox = find_child("ShowHints")
@onready var interaction_prompts_toggle	: CheckBox = find_child("ShowInteractionPrompts")

@onready var hud_scale_option   : OptionButton = find_child("HudScaleOption")

@onready var shadow_intensity_slider   : HSlider = find_child("ShadowIntensity")

@onready var adult_content_toggle : CheckBox = find_child("AdultContent")

var default_keybindings : Dictionary = {
	"up"		: [KEY_A],
	"down"		: [KEY_S],
	"left" 		: [KEY_A],
	"right"		: [KEY_D],
	"attack"	: [KEY_J],
	"stance" 	: [KEY_SPACE],
	"jump"		: [KEY_K],
	"run"		: [KEY_SHIFT],
}


func _ready() -> void:
	current_tab = 0
	get_tree().paused = true
	var screen_size : Vector2 = DisplayServer.window_get_size()
	match screen_size:
		Vector2(640, 360):
			resolution.selected = 0
		Vector2(1280, 720):
			resolution.selected = 1
		Vector2(1920, 1080):
			resolution.selected = 2

	noise_color_r.value = Ge.noise_color.r * 255.0
	noise_color_g.value = Ge.noise_color.g * 255.0
	noise_color_b.value = Ge.noise_color.b * 255.0
	noise_color_a.value = Ge.noise_color.a * 255.0

	noise_toggle.button_pressed = Ge.noise_enabled
	borderless_toggle.button_pressed = Options.borderless

	master_volume_slider.value	= AudioServer.get_bus_volume_db(master_bus_id)
	sfx_volume_slider.value		= AudioServer.get_bus_volume_db(sfx_bus_id)
	efx_volume_slider.value 	= AudioServer.get_bus_volume_db(efx_bus_id)
	bgm_volume_slider.value 	= AudioServer.get_bus_volume_db(bgm_bus_id)

	tutorial_toggle.button_pressed	= Ge.show_tutorials
	hint_toggle.button_pressed		= Ge.show_hints
	interaction_prompts_toggle.button_pressed = Ge.show_interaction_prompts

	var hud_scale = Options.hud_scale
	match hud_scale:
		1:
			hud_scale_option.selected = 0
		2:
			hud_scale_option.selected = 1

	var shadow_intensity = Options.shadow_intensity
	shadow_intensity_slider.value = shadow_intensity

	adult_content_toggle.button_pressed = Options.adult_content_enabled


func _process(delta: float) -> void:
	Options.current_screen		= DisplayServer.window_get_current_screen()
	resolution.disabled			= Options.fullscreen
	borderless_toggle.disabled	= Options.fullscreen
	

	noise_color_rect.color = Color(noise_color_r.value/255.0, noise_color_g.value/255.0, noise_color_b.value/255.0, noise_color_a.value/255.0)

	slider_red_label.text	= "Red: " + str(int(noise_color_r.value))
	slider_green_label.text = "Green: " + str(int(noise_color_g.value))
	slider_blue_label.text	= "Blue: " + str(int(noise_color_b.value))
	slider_alpha_label.text	= "Alpha: " + str(int(noise_color_a.value))

func _exit_tree() -> void:
	get_tree().paused = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN )
	else:
		#_on_borderless_toggled(false)
		#borderless_toggle.button_pressed = Options.borderless
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Options.fullscreen = toggled_on
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

	DisplayServer.window_set_size(new_size)
	Options.window_size = new_size
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

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		print("Center window")
		DisplayServer.window_set_size(Options.window_size)
		var window_size = DisplayServer.window_get_size()
		var display_size = DisplayServer.screen_get_size()
		print("window_size: "+str(window_size))
		print("display_size: "+str(display_size))

		await get_tree().process_frame
		DisplayServer.window_set_position((display_size - window_size)/2)

		DisplayServer.window_set_current_screen(Options.current_screen)
		await get_tree().process_frame
		Options.save_options()

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
			ev.physical_keycode = key
			print("key: "+str(key))
			print("ev: "+str(ev))
			InputMap.action_add_event(action, ev)
	for button in get_tree().get_nodes_in_group("key_bind_buttons"):
		button.set_text_for_key()


func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_id, value)
	AudioServer.set_bus_mute(master_bus_id, value <= -10.0)
func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_id, value)
	AudioServer.set_bus_mute(sfx_bus_id, value <= -10.0)
func _on_efx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(efx_bus_id, value)
	AudioServer.set_bus_mute(efx_bus_id, value <= -10.0)
func _on_bgm_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bgm_bus_id, value)
	AudioServer.set_bus_mute(bgm_bus_id, value <= -10.0)

func _on_show_tutorials_toggled(toggled_on: bool) -> void:
	Ge.show_tutorials = toggled_on
	Options.save_options()


func _on_show_hints_toggled(toggled_on: bool) -> void:
	Ge.show_hints = toggled_on
	Options.save_options()


func _on_show_interaction_prompts_toggled(toggled_on: bool) -> void:
	Ge.show_interaction_prompts = toggled_on
	Options.save_options()


func _on_hud_scale_option_item_selected(index: int) -> void:
	match index:
		0:
			Options.hud_scale = 1
		1:
			Options.hud_scale = 2
	Options.save_options()


func _on_shadow_intensity_drag_ended(value_changed: bool) -> void:
	Options.shadow_intensity = shadow_intensity_slider.value
	Options.save_options()


func _on_adult_content_toggled(toggled_on: bool) -> void:
	Options.adult_content_enabled = toggled_on
	Options.save_options()
