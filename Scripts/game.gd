class_name Game extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"


const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const SAVE_PATH = "user://save1.ge"

@export var starting_map : String

var generated_rooms : Array[Vector3i]
var events : Array[String]
var custom_run : bool



func _ready() -> void:
	# ChatGPT explanation for '%' here: This is a "string name" literal (newer Godot 4.x syntax). It’s like writing "singleton" but stored as an immutable, interned string (faster for comparisons and memory-efficient).
	get_script().set_meta(&"singleton", self)

	MetSys.reset_state()
	MetSys.set_save_data()
	set_player($Kalin)

	room_loaded.connect(init_room, CONNECT_DEFERRED)
	load_room(starting_map)
	if get_node_or_null("Room/Marker2D"):
		player.position = $Room/Marker2D.position

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


func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

func reset_map_starting_coords() -> void:
	%MapWindow.reset_starting_coords()

func init_room() -> void:
	MetSys.get_current_room_instance().adjust_camera_limits(player.pcam)
	player.on_enter()
	if MetSys.last_player_position.x == Vector2i.MAX.x:
		#MetSys.set_player_position(player.position)
		MetSys.set_player_position(player.position)
