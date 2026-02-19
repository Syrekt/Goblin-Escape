extends Node


var inputs : Dictionary
var last_input_type := "keyboard"
var jump_key	: String
var attack_key	: String
var stance_key 	: String
var crouch_key 	: String
var grab_key	: String
var run_key		: String

var loading := false
var game_start := true ## First time opening start menu, don't pause the game

var camera_focus : Node2D

var save_data : Dictionary
var save_slot := "save1"

var show_noise_this_room := true

var BALLOON = preload("res://Objects/balloon.tscn")

var noise_enabled := false:
	set(v):
		noise_enabled = v
var noise_color : Color = Color(1, 1, 1, 0.05):
	set(v):
		noise_color = v

var show_tutorials := true:
	set(v):
		show_tutorials = v
var show_hints := true:
	set(v):
		show_hints = v
var show_interaction_prompts := true:
	set(v):
		show_interaction_prompts = v


signal show_combat_tutorial
signal show_stealth_tutorial
signal show_patrol_tutorial

var player : Player

func _ready() -> void:
	show_combat_tutorial.connect(_show_combat_tutorial)
	show_stealth_tutorial.connect(_show_stealth_tutorial)
	show_patrol_tutorial.connect(_show_patrol_tutorial)


	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device_id:int,connected:bool) -> void:
	if connected:
		print("Gamepad connected: %s" %device_id)
	else:
		print("Gamepad disconnected: %s" %device_id)
		if !get_tree().current_scene.find_child("IngameMenu"):
			var menu = load("res://UI/ingame_menu.tscn").instantiate()
			add_child(menu)



func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		Options.fullscreen = !Options.fullscreen
		if Options.fullscreen:	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		notification(NOTIFICATION_WM_SIZE_CHANGED)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		last_input_type = "gamepad"
	elif event is InputEventKey || event is InputEventMouse:
		last_input_type = "keyboard"


#region Methods

func _show_combat_tutorial():
	print("Show combat tutorial")
	var combat_tutorial_scene := load("res://Tutorial/combat_tutorial.tscn")
	var combat_tutorial = combat_tutorial_scene.instantiate()
	get_tree().current_scene.add_child(combat_tutorial)
func _show_stealth_tutorial():
	print("Show stealth tutorial")
	var stealth_tutorial_scene := load("res://Tutorial/stealth_tutorial.tscn")
	var stealth_tutorial = stealth_tutorial_scene.instantiate()
	get_tree().current_scene.add_child(stealth_tutorial)
func _show_patrol_tutorial():
	print("Show patrol tutorial")
	var patrol_tutorial_scene := load("res://Tutorial/enemy_patrol_tutorial.tscn")
	var patrol_tutorial = patrol_tutorial_scene.instantiate()
	get_tree().current_scene.add_child(patrol_tutorial)


func string_array_get_random(array: PackedStringArray) -> String:
	var i = randi() % array.size()
	return array[i]
func play_audio_from_string_array(position: Vector2, volume: float, path: String) -> void:
	var emitter : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	emitter.max_distance = 256;
	emitter.global_position = position
	emitter.bus = "SFX"
	add_child(emitter)

	if !DirAccess.dir_exists_absolute(path): push_error("Path <%s> doesn't exists!", path)
	var array = DirAccess.get_files_at(path)
	var sound = string_array_get_random(array)
	if sound.ends_with(".import"):
		sound = sound.get_basename()

	emitter.volume_db = volume
	emitter.stream = load(path + "/" + sound)
	emitter.play()
	emitter.finished.connect(emitter.queue_free)
## emits audio from emitter
func play_audio(emitter: AudioStreamPlayer2D, volume: int, audio_path: String) -> void:
	emitter.volume_db = volume
	emitter.stream = load(audio_path)
	emitter.play()
## Plays non-directional audio
func play_audio_free(volume: int, audio_path: String) -> void:
	## Plays a non-directional sound
	var audio_emitter = AudioStreamPlayer.new()
	add_sibling(audio_emitter)

	audio_emitter.volume_db = volume
	audio_emitter.stream = load(audio_path)
	audio_emitter.bus = "SFX"
	audio_emitter.finished.connect(audio_emitter.queue_free)
	audio_emitter.play()
func EmitNoise(source: CharacterBody2D, position: Vector2, amount: float, loud := false) -> void:
	var noise = load("res://Objects/noise.tscn").instantiate()
	noise.amount_max = amount
	noise.position = position
	noise.source = source
	noise.loud = loud

	get_tree().current_scene.add_child(noise)
func UpdateNoiseIndicator() -> void:
	Ge.show_noise_this_room = false
	var game = Game.get_singleton()
	for child in game.map.get_children():
		if child is Enemy && child.state_node.state.name != "death":
			Ge.show_noise_this_room = true
			child.assign_player(player)
func save_node(node, data: Dictionary) -> void:
	print("Save node: %s" % node.name)
	var json = JSON.stringify(data)
	data["filename"] = node.get_scene_file_path()
	data["parent"] = node.get_parent().get_path()
	data["name"] = node.name
	data["pos_x"] = node.position.x;
	data["pos_y"] = node.position.y
	save_data.set(node.get_path(), data)

var popup_scene = preload("res://Objects/text_pop_up.tscn")
func popup_text(position: Vector2, text: String, color1 := Color.WHITE, color2 := Color.WHITE) -> void:
	var popup = popup_scene.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = position - Vector2(0, 20)
	popup.label.text = text
	popup.tween_begin(color1, color2)
var tween_slow_mo : Tween
func slow_mo(amount: float, time: float) -> void:
	if tween_slow_mo:
		tween_slow_mo.kill()
	tween_slow_mo = create_tween().bind_node(self)
	tween_slow_mo.tween_property(Engine, "time_scale", amount, 0.0)
	tween_slow_mo.tween_property(Engine, "time_scale", 1, time)
func hit_stop(time: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(time, true).timeout
	get_tree().paused = false
func kill_slow_mo() -> void:
	Engine.time_scale = 1.0
	if tween_slow_mo && tween_slow_mo.is_running():
		tween_slow_mo.kill()
		tween_slow_mo = null
var bleed_burst_scene = load("res://VFX/blood_spurt.tscn")
func bleed_spurt(position: Vector2, dir: int) -> void:
	var part : GPUParticles2D = bleed_burst_scene.instantiate()
	part.global_position = position
	part.scale.x = dir
	part.emitting = true

	add_child(part)
var bleed_gush_scene = load("res://VFX/blood_gush.tscn")
func bleed_gush(position: Vector2, dir: int) -> void:
	var part : GPUParticles2D = bleed_gush_scene.instantiate()
	part.global_position = position
	part.scale.x = dir
	part.emitting = true

	add_child(part)
func play_particle(res: Resource, position: Vector2, dir := 1, rot := 0) -> void:
	var particle_controller : Node2D = res.instantiate()
	particle_controller.global_position = position
	for particle in particle_controller.get_children():
		particle.scale.x = dir
		particle.rotation = rot
		particle.emitting = true
		particle.z_index = 1

	add_child(particle_controller)
func dir_towards(from: Node2D, to: Node2D) -> int:
	return sign(to.global_position.x - from.global_position.x)
func set_camera_focus() -> void:
	var pcam : PhantomCamera2D = player.pcam
	pcam.follow_mode = pcam.FollowMode.GROUP
	var targets : Array[Node2D] = [player, camera_focus]
	#pcam.append_follow_targets_array(targets)
	pcam.set_follow_targets(targets)
	await get_tree().create_timer(0.5).timeout
func reset_camera_focus() -> void:
	var pcam : PhantomCamera2D = player.pcam
	pcam.erase_follow_targets(camera_focus)
	pcam.follow_mode = pcam.FollowMode.SIMPLE
	pcam.set_follow_target(player)
	await get_tree().create_timer(0.5).timeout
func walk_player() -> void:
	player.remote_control_input.append("right")
func stop_player() -> void:
	player.remote_control_input.erase("right")
func get_closest_node(from, group) -> Node:
	var closest : Node = null
	var min_dist = INF

	for node in get_tree().get_nodes_in_group(group):
		var dist = from.global_position.distance_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = node

	return closest
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if !Debugger.debug_mode:
			print("Save game before quitting")
			Game.get_singleton().save_game()
func one_shot_dialogue(text: String) -> void:
	var dialogue_resource = DialogueManager.create_resource_from_text("~ title\n" + text)
	var balloon = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, "title")
func get_action_keycode(action:String,return_full_path := false) -> String:
	#print("Get action keycode: "+str(action))
	var action_events = InputMap.action_get_events(action)
	#print("action_events: "+str(action_events))
	var action_keycode
	if action_events.size() > 0:
		for event in action_events:
			#print("event: "+str(event))
			if event is InputEventKey && last_input_type == "keyboard":
				if event.keycode != 0:
					action_keycode = OS.get_keycode_string(event.keycode)
				elif event.physical_keycode != 0:
					action_keycode = OS.get_keycode_string(event.physical_keycode)
				break
			elif event is InputEventJoypadButton && last_input_type == "gamepad":
				action_keycode = str(event.button_index)
				break
	#region Log
	#var crumb := SentryBreadcrumb.create("Get action keycode")
	#crumb.category = "Input"
	#crumb.level = SentrySDK.LEVEL_INFO
	#crumb.type = "info"
	#crumb.data = {
	#	"action": action,
	#	"action_keycode": action_keycode,
	#	"action_events": action_events,
	#}
	#SentrySDK.add_breadcrumb(crumb)
	#endregion
	if return_full_path:
		#res://UI/Buttons/
		var filepath := ""
		if last_input_type == "keyboard":
			filepath = "res://UI/Buttons/button_keyboard_" + action_keycode.to_lower() + ".png"
		elif last_input_type == "gamepad":
			filepath = "res://UI/Buttons/buttons_xbox" + action_keycode.to_lower() + ".png"

		if !ResourceLoader.exists(filepath):
			printerr("Can't find input icon %s" % filepath)
		print("Action keycode filepath found: " + str(action_keycode))
		return filepath

	#print("Action keycode found: " + str(action_keycode))
	return action_keycode
func fmod_play_event(event_name:String) -> void:
	FmodServer.play_one_shot("event:/" + event_name)
	#var event : FmodEvent = FmodServer.create_event_instance("event:/" + event_name)
	#event.attached = false
	#event.start()
func fmod_play_event_at(event_name:String,transform:Transform2D) -> void:
	var event = FmodServer.create_event_instance("event:/" + event_name)
	event.attached = true
	event.set_2d_attributes(transform)
	event.start()
func skip_stealth_tutorial() -> void:
	player.had_sword = true
	player.has_sword = true
	Game.get_singleton().persistent_values.set("Tutorial-Combat", true)
func notify(text:String) -> void:
	var _notification = Game.get_singleton().notification
	_notification.label.text = text
	_notification.timer.start()
	#var balloon = preload("res://Objects/balloon.tscn").instantiate()
	#get_tree().current_scene.add_child(balloon)
	#var dialogue_resource = DialogueManager.create_resource_from_text("~ title\n" + "New tutorial added in options menu.")
	#balloon.start(dialogue_resource, "title")
#endregion
