extends Node


var inputs : Dictionary 
var jump_key : String
var attack_key : String
var stance_key : String
var crouch_key : String
var grab_key : String

var loading := false

var camera_focus : Node2D


signal show_combat_tutorial
signal show_stealth_tutorial

var player : Player

func _process(delta: float) -> void:
	Debugger.printui("player: "+str(player))


func _ready() -> void:

	show_combat_tutorial.connect(_show_combat_tutorial)
	show_stealth_tutorial.connect(_show_stealth_tutorial)
	var events = InputMap.action_get_events("jump")
	for event in events:
		if event is InputEventKey:
			jump_key = OS.get_keycode_string(event.physical_keycode).to_upper()
			print("jump_key: "+str(jump_key))

	events = InputMap.action_get_events("attack")
	for event in events:
		if event is InputEventKey:
			attack_key = OS.get_keycode_string(event.physical_keycode).to_upper()
			print("attack_key: "+str(attack_key))

	events = InputMap.action_get_events("stance")
	for event in events:
		if event is InputEventKey:
			stance_key = OS.get_keycode_string(event.physical_keycode).to_upper()
			print("stance_key: "+str(stance_key))

	events = InputMap.action_get_events("down")
	for event in events:
		if event is InputEventKey:
			crouch_key = OS.get_keycode_string(event.physical_keycode).to_upper()
			print("crouch_key: "+str(crouch_key))

	events = InputMap.action_get_events("grab")
	for event in events:
		if event is InputEventKey:
			grab_key = OS.get_keycode_string(event.physical_keycode).to_upper()
			print("grab_key: "+str(grab_key))

func _show_combat_tutorial():
	print("Show combat tutorial")
	var combat_tutorial_scene := load("res://Tutorial/combat_tutorial.tscn")
	var combat_tutorial = combat_tutorial_scene.instantiate()
	add_child(combat_tutorial)
func _show_stealth_tutorial():
	print("Show stealth tutorial")
	var stealth_tutorial_scene := load("res://Tutorial/stealth_tutorial.tscn")
	var stealth_tutorial = stealth_tutorial_scene.instantiate()
	stealth_tutorial.tree_exited.connect(_on_stealth_tutorial_tree_exited)
	add_child(stealth_tutorial)
func _on_stealth_tutorial_tree_exited() -> void:
	var balloon_scene := load("res://Objects/balloon.tscn")
	var balloon = balloon_scene.instantiate()
	add_child(balloon)


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
func save_game(filename: String) -> void:
	print("Saving...")
	var save_file = FileAccess.open("user://"+filename+".ge", FileAccess.WRITE)
	#save_file.store_line(get_tree().current_scene.scene_file_path)
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
		var node_data = node.save()
		for prop in node.get_property_list():
			if prop.name == "save_list":
				for _node in node.save_list:
					print("_node.name: "+str(_node.name));
					node_data[_node.name] = _node.save()
		node_data["filename"] = node.get_scene_file_path()
		node_data["parent"] = node.get_parent().get_path()

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

	print("Game saved")
func load_game(filename: String) -> void:
	#get_tree().change_scene_to_file("res://Scenes/game.tscn")
	print("Loading...")

	loading = true
	get_tree().paused = true

	var loading_screen = get_tree().current_scene.find_child("LoadingScreen")
	loading_screen.show()

	if !FileAccess.file_exists("user://"+filename+".ge"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persistent")
	print("save_nodes: "+str(save_nodes))
	for i in save_nodes:
		print("i: "+str(i))
		i.queue_free()
	
	await get_tree().process_frame
	

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://"+filename+".ge", FileAccess.READ)
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
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		if new_object.has_signal("on_load"): # Not used
			new_object.emit_signal("on_load")

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
	loading = false
	print("Game loaded.")
	get_tree().paused = false
	await get_tree().create_timer(1.0).timeout
	loading_screen.hide()

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
