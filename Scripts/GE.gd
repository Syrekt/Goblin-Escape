extends Node

var loading := false

signal show_combat_tutorial

func _ready() -> void:
	show_combat_tutorial.connect(_show_combat_tutorial)
func _show_combat_tutorial():
	print("Show combat tutorial")
	var combat_tutorial_scene : PackedScene = load("res://Objects/combat_tutorial.tscn")
	var combat_tutorial = combat_tutorial_scene.instantiate()
	add_child(combat_tutorial)


func string_array_get_random(array: PackedStringArray) -> String:
	var i = randi() % array.size()
	return array[i]
func play_audio_from_string_array(emitter: AudioStreamPlayer2D, volume: float, path: String) -> void:
	if !DirAccess.dir_exists_absolute(path): push_error("Path <%s> doesn't exists!", path)
	var array = DirAccess.get_files_at(path)
	var sound = string_array_get_random(array)
	if sound.ends_with(".import"):
		sound = sound.get_basename()
	
	emitter.volume_db = volume
	emitter.stream = load(path + "/" + sound)
	emitter.play()
## emits audio from emitter
func play_audio(emitter: AudioStreamPlayer2D, volume: int, audio_path: String) -> void:
	emitter.volume_db = volume
	emitter.stream = load(audio_path)
	emitter.play()
## Plays non-directional audio
func play_audio_free(volume: int, audio_path: String) -> void:
	## Plays a non-directional sound
	var player = AudioStreamPlayer.new()
	add_sibling(player)

	player.volume_db = volume
	player.stream = load(audio_path)
	player.finished.connect(player.queue_free)
	player.play()
func EmitNoise(source: CharacterBody2D, position: Vector2, amount: float) -> void:
	var noise = load("res://Objects/noise.tscn").instantiate()
	noise.amount_max = amount
	noise.position = position
	noise.source = source

	get_tree().current_scene.add_child(noise)
func save_game() -> void:
	print("Saving...")
	var save_file = FileAccess.open("user://savegame.ge", FileAccess.WRITE)
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
func load_game() -> void:
	print("Loading...")

	loading = true
	get_tree().paused = true

	var loading_screen = get_node("/root/Game/CanvasLayer/LoadingScreen")
	loading_screen.show()

	if not FileAccess.file_exists("user://savegame.ge"):
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

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.ge", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
	loading = false
	print("Game loaded.")

var popup_scene = preload("res://Objects/text_pop_up.tscn")
func popup_text(position: Vector2, text: String, color1 := Color.WHITE, color2 := Color.WHITE) -> void:
	var popup = popup_scene.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = position - Vector2(0, 20)
	popup.label.text = text
	popup.tween_begin(color1, color2)
func slow_mo() -> void:
	var tween = create_tween().bind_node(self)
	tween.tween_property(Engine, "time_scale", 0.5, 0.0)
	tween.tween_property(Engine, "time_scale", 1, 1.0)
