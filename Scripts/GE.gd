extends Node


var inputs : Dictionary 
var jump_key	: String
var attack_key	: String
var stance_key 	: String
var crouch_key 	: String
var grab_key	: String
var run_key		: String

var loading := false

var camera_focus : Node2D

var last_checkpoint : Checkpoint

var save_data : Dictionary
var save_slot := "save1"

var BALLOON = preload("res://Objects/balloon.tscn")

signal show_combat_tutorial
signal show_stealth_tutorial

var player : Player

func _ready() -> void:

	show_combat_tutorial.connect(_show_combat_tutorial)
	show_stealth_tutorial.connect(_show_stealth_tutorial)

	assign_key("jump", "jump_key")
	assign_key("attack", "attack_key")
	assign_key("stance", "stance_key")
	assign_key("down", "down_key")
	assign_key("grab", "grab_key")
	assign_key("run", "run_key")

func assign_key(action: String, value: String) -> void:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			set(value, OS.get_keycode_string(event.physical_keycode).to_upper())
			print(action + "_key: " + str(run_key))

func _show_combat_tutorial():
	print("Show combat tutorial")
	var combat_tutorial_scene := load("res://Tutorial/combat_tutorial.tscn")
	var combat_tutorial = combat_tutorial_scene.instantiate()
	add_child(combat_tutorial)
func _show_stealth_tutorial():
	print("Show stealth tutorial")
	var stealth_tutorial_scene := load("res://Tutorial/stealth_tutorial.tscn")
	var stealth_tutorial = stealth_tutorial_scene.instantiate()
	add_child(stealth_tutorial)


func string_array_get_random(array: PackedStringArray) -> String:
	var i = randi() % array.size()
	return array[i]
func play_audio_from_string_array(position: Vector2, volume: float, path: String) -> void:
	var emitter : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	emitter.max_distance = 256;
	emitter.global_position = position
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
	audio_emitter.finished.connect(audio_emitter.queue_free)
	audio_emitter.play()
func EmitNoise(source: CharacterBody2D, position: Vector2, amount: float) -> void:
	var noise = load("res://Objects/noise.tscn").instantiate()
	noise.amount_max = amount
	noise.position = position
	noise.source = source

	get_tree().current_scene.add_child(noise)
func save_node(node, data: Dictionary) -> void:
	print("Save node: %s" % node.name)
	var json = JSON.stringify(data)
	data["filename"] = node.get_scene_file_path() 
	data["parent"] = node.get_parent().get_path() 
	data["name"] = node.name
	save_data.set(node.get_path(), data)
func save_game() -> void:
	print("Saving...")
	var save_file = FileAccess.open("user://"+save_slot+".ge", FileAccess.WRITE)

	if last_checkpoint:
		save_data["globals"] = {
			"last checkpoint" : {
				"parent": last_checkpoint.get_parent().get_path(),
				"filename": last_checkpoint.get_scene_file_path(),
			}
		}

	var save_nodes = get_tree().get_nodes_in_group("Persistent")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		node.save()
		#for prop in node.get_property_list():
		#	if prop.name == "save_list":
		#		for _node in node.save_list:
		#			print("_node.name: "+str(_node.name));
		#			node_data[_node.name] = _node.save()
		#node_data["filename"] = node.get_scene_file_path()
		#node_data["parent"] = node.get_parent().get_path()

		## JSON provides a static method to serialized JSON string.
		#var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		#save_file.store_line(json_string)

	save_file.store_line(JSON.stringify(save_data))
	save_file.close()
	print("Game saved: %s" % save_file.get_path())
func load_game() -> void:
	#get_tree().change_scene_to_file("res://Scenes/demo_map.tscn")
	print("Loading...")
	var save_file = FileAccess.open("user://"+save_slot+".ge", FileAccess.READ)
	if !save_file:
		print("Save file corrupt or doesn't exist")
		return

	loading = true
	get_tree().paused = true

	var loading_screen = get_tree().current_scene.find_child("LoadingScreen")
	loading_screen.show()

	# Decided to remove the font anyway
	var tween_font = create_tween().bind_node(loading_screen)
	var font = loading_screen.find_child("Label")
	font.set("theme_override_colors/font_color", Color.WHITE)
	tween_font.tween_property(font, "theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 0.0), 0.5)

	var tween_rect = create_tween().bind_node(loading_screen)
	var rect = loading_screen.find_child("ColorRect")
	rect.color = Color.BLACK
	tween_rect.tween_property(rect, "color", Color(0.0, 0.0, 0.0, 0.0), 1)

	#if !FileAccess.file_exists("user://"+filename+".ge"):
	#	return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persistent")
	print("save_nodes: "+str(save_nodes))
	for i in save_nodes:
		i.queue_free()
	
	await get_tree().process_frame
	

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if !parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		save_data = json.data
		print("parse_result: "+str(parse_result))
		for i in save_data.keys():
			print("Loading key(%s)" % i)
			if i == "globals":
				var globals = save_data[i]
				if globals.has("last checkpoint"):
					var checkpoint = globals["last checkpoint"]
					find_child(checkpoint.filename)
				continue
			var node_data = save_data[i]
			# Firstly, we need to create the object and add it to the tree and set its position.
			var new_object = load(node_data["filename"]).instantiate()
			print("New object created: %s" % new_object.name)

			#var new_object = load(node_data["filename"]).instantiate()
			#get_node(node_data["parent"]).add_child(new_object)
			#new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

			get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
			new_object.name = node_data["name"]
			if new_object is Player:
				# Assign player id to global variable
				Ge.player = new_object
				new_object.pcam.follow_damping = false

			# Remove unnecessary keys
			node_data.erase("filename")
			node_data.erase("parent")
			node_data.erase("pos_x")
			node_data.erase("pos_y")

			# Now we set the remaining variables.
			if new_object.has_method("load"):
				new_object.load(node_data)
			else:
				for value in node_data:
					new_object.set(value, node_data[value])

			# We can use this if something needs to be done after loading the node
			if new_object.has_signal("on_load"): # Not used
				new_object.emit_signal("on_load")

	# Assign player id to every enemy
	get_tree().current_scene.player_ready.emit(player)

	loading = false
	save_file.close()
	print("Game loaded.")
	get_tree().paused = false
	await get_tree().create_timer(1.0).timeout
	Ge.player.pcam.follow_damping = true
	# loading_screen.hide()
	for node in get_tree().current_scene.get_children():
		if node is Control:
			print("%s | mouse filter=%s | path=%s" % [node.name, node.mouse_filter, node.get_path()])

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
	var pcam : PhantomCamera2D = player.find_child("PhantomCamera2D")
	pcam.follow_mode = pcam.FollowMode.GROUP
	var targets : Array[Node2D] = [player, camera_focus]
	pcam.append_follow_targets_array(targets)
	await get_tree().create_timer(0.5).timeout
func reset_camera_focus() -> void:
	var pcam : PhantomCamera2D = player.find_child("PhantomCamera2D")
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
		print("Save game before quitting")
		save_game()
func one_shot_dialogue(text: String) -> void:
	var dialogue_resource = DialogueManager.create_resource_from_text("~ title\n" + text)
	var balloon = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, "title")
