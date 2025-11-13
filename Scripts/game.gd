class_name Game extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"


const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const SAVE_PATH = "user://save1.ge"

@export var starting_map : String

var loading := false
var generated_rooms : Array[Vector3i]
var events : Array[String]
var custom_run : bool
var rooms : Dictionary
var persistent_values : Dictionary
var checkpoint : Dictionary
var experience_drop = preload("res://Objects/dropped_experience.tscn")
var dropped_exp : Dictionary

signal world_refreshed


func _ready() -> void:
	# ChatGPT explanation for '%' here: This is a "string name" literal (newer Godot 4.x syntax). It’s like writing "singleton" but stored as an immutable, interned string (faster for comparisons and memory-efficient).
	get_script().set_meta(&"singleton", self)

	MetSys.reset_state()
	MetSys.set_save_data()
	set_player($Kalin)

	room_loaded.connect(init_room, CONNECT_DEFERRED)
	room_loaded.connect(player.camera._on_room_load, CONNECT_DEFERRED)
	load_room(starting_map)

	if MetSys.current_room && MetSys.current_room.spawn_point:
		player.position = MetSys.current_room.spawn_point.position

	# ^ replaces NodePath
	var start := map.get_node_or_null(^"SavePoint")
	if start && !custom_run:
		player.position = start.position

	# Add module for room transitions.
	add_module("RoomTransitions.gd")
	# You can enable alternate transition effect by using this module instead.
	#add_module("ScrollingRoomTransitions.gd")

	# Reset position tracking (feature specific to this project).
	await get_tree().physics_frame
	reset_map_starting_coords.call_deferred()

	%Minimap.set_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 8)

	world_refreshed.connect(_on_world_refreshed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		print("restart")
		player.position = MetSys.current_room.spawn_point.position



static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

func save_game() -> void:
	print("Save game")
	var save_manager := SaveManager.new()
	save_manager.set_value("generated_rooms", generated_rooms)
	save_manager.set_value("events", events)
	save_manager.set_value("current_room", MetSys.get_current_room_name())
	save_manager.set_value("rooms", rooms)
	save_manager.set_value("persistent_values", persistent_values)
	save_manager.set_value("checkpoint", checkpoint)
	player.save(save_manager)
	save_room()
	save_manager.save_as_text(SAVE_PATH)

func save_room() -> void:
	var save_manager := SaveManager.new()
	var room_data = rooms.get(map.name)
	var persistent_nodes = get_tree().get_nodes_in_group("Persistent")
	for node in persistent_nodes:
		print("Save %s" %node)
		room_data.set(node.name, node.save())

	# Get enemies in group
	var enemies = get_tree().get_nodes_in_group("Enemy")
	# Save each enemy to enemy data
	var enemy_data : Dictionary
	for enemy in enemies:
		enemy_data.set(enemy.name, enemy.save())
	# Give enemy data to room data
	room_data.set("Enemies", enemy_data)
	# Save enemy data in room data
	rooms.set(map.name, room_data)

func load_game():
	loading = true
	if FileAccess.file_exists(SAVE_PATH):
		%LoadingScreen.tween_in()

		# If save data exists, load it using MetSys SaveManager.
		var save_manager := SaveManager.new()
		save_manager.load_from_text(SAVE_PATH)
		# Load room
		if not custom_run:
			var loaded_starting_map: String = save_manager.get_value("current_room")
			if not loaded_starting_map.is_empty(): # Some compatibility problem.
				starting_map = loaded_starting_map
		await load_room(starting_map)
		# Assign loaded values.
		generated_rooms.assign(save_manager.get_value("generated_rooms"))
		events.assign(save_manager.get_value("events"))
		rooms = save_manager.get_value("rooms")
		persistent_values = save_manager.get_value("persistent_values")
		if save_manager.get_value("checkpoint"):
			checkpoint = save_manager.get_value("checkpoint")
		player.load(save_manager.get_value("kalin"))

		var room_data : Dictionary = rooms.get(map.name)
		if room_data:
			var persistent_nodes = get_tree().get_nodes_in_group("Persistent")
			for node in persistent_nodes:
				var node_data = room_data.get(node.name)
				if node_data:
					node.load(node_data)

		
	else:
		# If no data exists, set empty one.
		MetSys.set_save_data()
	
	await get_tree().create_timer(0.1).timeout
	loading = false


func reset_map_starting_coords() -> void:
	%MapWindow.reset_starting_coords()

func init_room() -> void:
	MetSys.get_current_room_instance().adjust_camera_limits(player.pcam)
	player.on_enter()

	if MetSys.last_player_position.x == Vector2i.MAX.x:
		MetSys.set_player_position(player.position)

	if !rooms:
		rooms = { map.name: {} }
	elif !rooms.get(map.name):
		rooms.set(map.name, {})

	if dropped_exp:
		if dropped_exp.room == map.name:
			var _exp = experience_drop.instantiate()
			_exp.amount = dropped_exp.amount
			_exp.position = Vector2(dropped_exp.pos_x, dropped_exp.pos_y)


func _on_world_refreshed() -> void:
	print("Refresh world")
	for child in map.get_children():
		print("child: "+str(child))
		if child is Enemy:
			child.reset()
	for key in rooms.keys():
		rooms.get(key).erase("Enemies")
func save_data_in_room(key:String,data:Dictionary) -> void:
	var room = rooms.get(map.name)
	room.set(key, data)
func get_data_in_room(_name:String) -> Variant:
	var room = rooms.get(map.name)
	if !room: return null
	var data = room.get(_name)
	if !data: return null
	return data
