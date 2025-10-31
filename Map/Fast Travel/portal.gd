class_name Portal extends Interaction

@export var inert := true
var map_icon := "portal"
var draw_on_map := true

@onready var map_scene : PackedScene = preload("res://UI/map.tscn")


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
	save()
func use() -> void:
	pass

func save() -> void:
	Ge.save_node(self,{
		"inert": false,
	})
func load(data: Dictionary) -> void:
	inert = data.get(inert, true)
	if !inert:
		$Sprite.play("active")
		$Light.enabled = true
