class_name StartMenu extends CanvasLayer


var ingame_menu = preload("res://UI/ingame_menu.tscn")
var ingame_menu_inst : IngameMenu = null

var can_quit_via_escape := false

@onready var fmod_bgm_event: FmodEventEmitter2D = $"../FModBGMEvent"
@onready var feedback: Button = $Control/NinePatchRect/TextureRect/Feedback
@onready var last_version: Button = $Control/NinePatchRect/TextureRect/LastVersion

func _enter_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if !Ge.game_start:
		get_tree().paused = true
		var player = Game.get_singleton().player
		if player: player._on_fullscreen_panel_opened()

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if !Ge.game_start:
		get_tree().paused = false
		var player = Game.get_singleton().player
		if player: player._on_fullscreen_panel_closed()
	Ge.game_start = false


func _ready() -> void:
	Talo.game_config.get_live_config()
	$Control/NinePatchRect/TextureRect/VBoxContainer/StartGame.grab_focus()
	if Options.update_available:
		last_version.text = "Update Available!"
	else:
		last_version.text = "Patreon"
	return
	if OS.is_debug_build():
		queue_free()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") && can_quit_via_escape:
		_on_start_game_pressed()

func _on_start_game_pressed() -> void:
	var player : Player = Game.get_singleton().player
	var pcam : PhantomCamera2D = player.pcam
	create_tween().bind_node(player).tween_property(pcam, "zoom", Vector2(1, 1), 1.0)
	#pcam.set_zoom(Vector2(1, 1))
	create_tween().bind_node(player).tween_property(pcam, "follow_offset", Vector2(0, 0), 1.0)
	#pcam.set_follow_offset(Vector2(0, 0))
	pcam.set_follow_damping_value(Vector2(0.1, 0.1))
	pcam.set_follow_damping(true)
	if !player.state_node.state_changed.is_connected(player._on_state_machine_state_changed):
		player.state_node.state_changed.connect(player._on_state_machine_state_changed)

	var area = MetSys.get_current_room_instance().area
	FmodServer.set_global_parameter_by_name("Area", area)
	fmod_bgm_event.volume = 1.0

	queue_free()


func _on_options_pressed() -> void:
	ingame_menu_inst = ingame_menu.instantiate()
	add_child(ingame_menu_inst)
	ingame_menu_inst.close_button.pressed.connect(_on_ingame_menu_close_button_pressed)
	hide()


func _on_steam_pressed() -> void:
	OS.shell_open("https://store.steampowered.com/developer/psychoseel")


func _on_itch_pressed() -> void:
	OS.shell_open("https://psychoseel.itch.io/")


func _on_discord_pressed() -> void:
	OS.shell_open("https://discord.gg/e28ByRr")


func _on_exit_pressed() -> void:
	get_tree().quit()



func _on_ingame_menu_close_button_pressed() -> void:
	show()


func _on_last_version_pressed() -> void:
	if Options.update_available:
		OS.shell_open(Options.update_link)
	else:
		OS.shell_open("https://www.patreon.com/psychoseel")


func _on_feedback_pressed() -> void:
	OS.shell_open("https://forms.gle/NtqqKGXcuoDEGdqw8")


func _on_bug_report_pressed() -> void:
	OS.shell_open("https://forms.gle/GMYr4ZYZbhsCgzFe8")


func _on_block_escape_timer_timeout() -> void:
	can_quit_via_escape = true
