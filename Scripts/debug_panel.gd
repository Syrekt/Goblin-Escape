extends CanvasLayer

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

func _ready() -> void:
	if OS.is_debug_build():
		%VersionNumber.visible = false
	else:
		queue_free()
		return

	map_selection.set_item_count(scenes.size())
	for i in range(scenes.size()):
		print("i: "+str(i))
		map_selection.set_item_text(i, scenes[i])
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		visible = !visible

func _on_hide_version_toggled(toggled_on: bool) -> void:
	%VersionNumber.visible = toggled_on


func _on_deal_damage_pressed() -> void:
	Game.get_singleton().player.take_damage(90)



func _on_map_selection_item_selected(index: int) -> void:
	var game = Game.get_singleton()
	game.load_room("res://Rooms/" + map_selection.get_item_text(index) + ".tscn")
	if MetSys.current_room && MetSys.current_room.spawn_point:
		game.player.position = MetSys.current_room.spawn_point.position


func _on_heal_kalin_pressed() -> void:
	Game.get_singleton().player.health.value += 10000


func _on_give_exp_pressed() -> void:
	Game.get_singleton().player.experience.add(1000)
