class_name Portal extends Interaction

@export var inert := true
var map_icon := "portal"
var draw_on_map := true
@export_file("room_link") var target_map : String

@onready var map_scene : PackedScene = preload("res://UI/map.tscn")

func _ready() -> void:
	var game = Game.get_singleton()
	await game.room_loaded
	var save_data = game.get_data_in_room(name)
	if save_data:
		load_data(save_data)
	

func update(player: Player) -> void:
	active = !inert
	draw_on_map = !inert


	if player.just_pressed("interact"):
		if inert:
			activate()
		else:
			var map : Map = map_scene.instantiate()
			map.teleporting		= true
			map.portal_from		= self
			map.portal_target	= self
			get_tree().current_scene.add_child(map)

	if inert:
		return

func activate() -> void:
	inert = false
	$Light.enabled = true
	$Sprite.play("active")
	Game.get_singleton().save_data_in_room(name, {"inert": false})
func use() -> void:
	pass
func load_data(data: Dictionary) -> void:
	inert = data.get(inert, true)
	if !inert:
		$Sprite.play("active")
		$Light.enabled = true
