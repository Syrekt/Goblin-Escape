extends TabContainer


@onready var resolution : OptionButton = find_child("Resolution")

@onready var noise_color_r : HSlider = find_child("NoiseColorRedSlider")
@onready var noise_color_g : HSlider = find_child("NoiseColorGreenSlider")
@onready var noise_color_b : HSlider = find_child("NoiseColorBlueSlider")
@onready var noise_color_a : HSlider = find_child("NoiseColorAlphaSlider")

@onready var noise_toggle : CheckButton = find_child("NoiseToggleCheckButton")

@onready var slider_red_label : Label = find_child("Red").find_child("Label")
@onready var slider_green_label : Label = find_child("Green").find_child("Label")
@onready var slider_blue_label : Label = find_child("Blue").find_child("Label")
@onready var slider_alpha_label : Label = find_child("Alpha").find_child("Label")

@onready var noise_color_rect : ColorRect = find_child("NoiseColorRect")



func _ready() -> void:
	get_tree().paused = true
	var screen_size : Vector2 = DisplayServer.window_get_size()
	match screen_size:
		Vector2(640, 480):
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

func _process(delta: float) -> void:
	resolution.disabled = Options.fullscreen

	noise_color_rect.color = Color(noise_color_r.value/255.0, noise_color_g.value/255.0, noise_color_b.value/255.0, noise_color_a.value/255.0)

	slider_red_label.text	= "Red: " + str(int(noise_color_r.value))
	slider_green_label.text = "Green: " + str(int(noise_color_g.value))
	slider_blue_label.text	= "Blue: " + str(int(noise_color_b.value))
	slider_alpha_label.text	= "Alpha: " + str(int(noise_color_a.value))

func _exit_tree() -> void:
	get_tree().paused = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	Options.fullscreen = toggled_on
	var window_size = DisplayServer.window_get_size()
	var display_size = DisplayServer.window_get_size()
	notification(NOTIFICATION_WM_SIZE_CHANGED)

func _on_option_button_item_selected(index: int) -> void:
	var new_size : Vector2
	match index:
		0:
			new_size = Vector2(640, 480)
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
		var window_size = DisplayServer.window_get_size()
		var display_size = DisplayServer.screen_get_size()
		print("window_size: "+str(window_size))
		print("display_size: "+str(display_size))
		DisplayServer.window_set_position((display_size - window_size)/2)
		Options.save_options()

func _on_center_window_pressed() -> void:
	notification(NOTIFICATION_WM_SIZE_CHANGED)


func _on_noise_color_red_slider_drag_ended(value_changed: bool) -> void:
	print("noise_color_r.value: "+str(noise_color_r.value));
	Ge.noise_color.r = noise_color_r.value / 255.0


func _on_noise_color_green_slider_drag_ended(value_changed: bool) -> void:
	print("noise_color_g.value: "+str(noise_color_g.value));
	Ge.noise_color.g = noise_color_g.value / 255.0


func _on_noise_color_blue_slider_drag_ended(value_changed: bool) -> void:
	print("noise_color_b.value: "+str(noise_color_b.value));
	Ge.noise_color.b = noise_color_b.value / 255.0


func _on_noise_color_alpha_slider_drag_ended(value_changed: bool) -> void:
	print("noise_color_a.value: "+str(noise_color_a.value));
	Ge.noise_color.a = noise_color_a.value / 255.0


func _on_check_button_toggled(toggled_on: bool) -> void:
	Ge.noise_enabled = toggled_on
