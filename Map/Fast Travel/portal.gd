class_name Portal extends Interaction

@export var inert := true
var map_icon := "portal"
var draw_on_map := true
@export_file("room_link") var target_map : String

@onready var map_scene : PackedScene = preload("res://UI/map.tscn")

@onready var background_sprite : AnimatedSprite2D = $BackgroundSprite
@onready var base_sprite : AnimatedSprite2D = $BaseSprite

func _ready() -> void:
	var game = Game.get_singleton()
	await game.room_loaded
	var save_data = game.get_data_in_room(name)
	if save_data:
		load_data(save_data)
	if inert:
		background_sprite.hide()
	

func update(player: Player) -> void:
	active = !inert
	draw_on_map = !inert


	if player.just_pressed("interact"):
		if inert:
			activate()
		else:
			print("Use portal")

	if inert:
		return

func activate() -> void:
	inert = false
	$Light.enabled = true
	base_sprite.play("active")
	background_sprite.show()
	background_sprite.play("activating")
	Game.get_singleton().save_data_in_room(name, {"inert": false})
func load_data(data: Dictionary) -> void:
	inert = data.get(inert, true)
	if !inert:
		base_sprite.play("active")
		background_sprite.play("active")
		$Light.enabled = true


func _on_background_sprite_animation_finished() -> void:
	print("animation: "+str(background_sprite.animation));
	if background_sprite.animation == "activating":
		background_sprite.play("active")
