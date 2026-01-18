class_name DebugPanel extends CanvasLayer

var scenes : Array[String] = [
	"TestRoom",
	"StartingRoom",
	"SwordRoom",
	"StealthTutorial1",
	"SlideTutorial",
	"MovementRoom",
	"JumpingPuzzle1",
	"HeavyStanceRoom",
	"HeavyStancePath1",
	"HeavyStancePath2",
	"HeavyStancePath3",
	"HeavyStancePath4",
	"DemoLastRoom",
	"DefensiveStanceRoom",
	"DefensiveStancePath1",
	"DefensiveStancePath2",
	"DefensiveStancePath3",
	"DefensiveStancePath4",
	"DefensiveStancePathExit1",
	"DefensiveStancePathExit2",
	"Corridor1",
	"Corridor2",
	"Corridor3",
	"CentralRoom1",
	"CentralRoom2",
]

@onready var map_selection: OptionButton = $Control/NinePatchRect/MarginContainer/VBoxContainer/MapSelection
var map_selected := false ## We've selected map from debug panel so teleport player to spawn point in the next room

@onready var camera_zoom: HSlider = $Control/NinePatchRect/MarginContainer/VBoxContainer/HSplitContainer/CameraZoom

func _ready() -> void:
	get_script().set_meta(&"singleton", self)
	if OS.is_debug_build():
		%VersionNumber.visible = false
	else:
		queue_free()
		return

	map_selection.set_item_count(scenes.size())
	for i in range(scenes.size()):
		map_selection.set_item_text(i, scenes[i])

		
static func get_singleton() -> DebugPanel:
	return (DebugPanel as Script).get_meta(&"singleton") as DebugPanel

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		visible = !visible
		camera_zoom.value = Game.get_singleton().player.pcam.zoom.x
		if visible:
			get_tree().paused = true
		else:
			get_tree().paused = false

func _on_hide_version_toggled(toggled_on: bool) -> void:
	%VersionNumber.visible = !toggled_on


func _on_deal_damage_pressed() -> void:
	Game.get_singleton().player.take_damage(90)


func _on_map_selection_item_selected(index: int) -> void:
	var game = Game.get_singleton()
	game.load_room("res://Rooms/" + map_selection.get_item_text(index) + ".tscn")
	map_selected = true

func _on_room_assigned(spawn_point:Node2D) -> void:
	if !map_selected: return

	if !spawn_point:
		print("No spawn point assigned in this room")
		return

	var player = Game.get_singleton().player
	player.global_position = spawn_point.global_position
	


func _on_heal_kalin_pressed() -> void:
	Game.get_singleton().player.health.value += 10000


func _on_give_exp_pressed() -> void:
	Game.get_singleton().player.experience.add(1000)


func _on_camera_zoom_value_changed(value: float) -> void:
	var player = Game.get_singleton().player
	player.pcam.zoom = Vector2(value, value)


func _on_status_effect_item_selected(index: int) -> void:
	var player = Game.get_singleton().player
	match index:
		0:
			player.status_effect_container.add_status_effect("Bleed", 30.0, 0.5)
