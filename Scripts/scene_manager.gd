extends Node2D

@onready var fog_sprite : Sprite2D = $FogSprite
@onready var ground_tiles : TileMapLayer = $BG
@onready var player : Player = $Kalin

var fog_image : Image
var vision_image : Image

signal player_ready
 
func _ready() -> void:
	generate_fog()

func _process(delta:float) -> void:
	if player.velocity.length():
		update_fog()

func generate_fog() -> void:
	var world_dimensions	= ground_tiles.get_used_rect().size * ground_tiles.tile_set.tile_size
	var world_position		= ground_tiles.get_used_rect().position * ground_tiles.tile_set.tile_size

	fog_image = Image.create(world_dimensions.x, world_dimensions.y, false, Image.Format.FORMAT_RGBAH)

	fog_image.fill(Color.BLACK)
	var fog_texture = ImageTexture.create_from_image(fog_image)
	fog_sprite.texture = fog_texture
	fog_sprite.global_position = world_position

	vision_image = $Kalin/VisionSprite.texture.get_image()
	vision_image.convert(Image.Format.FORMAT_RGBAH)

func update_fog() -> void:
	var vision_rect = Rect2(Vector2.ZERO, vision_image.get_size())
	fog_image.blend_rect(vision_image, vision_rect, player.global_position - Vector2(vision_image.get_size() / 2))
	var fog_texture = ImageTexture.create_from_image(fog_image)
	fog_sprite.texture = fog_texture

func _enter_tree() -> void:
	player_ready.connect(_on_player_ready)

func _on_player_ready(_player:Player) -> void:
	print("on player ready")
	Ge.player = _player
	for child in get_children():
		if child is Enemy:
			child.assign_player(_player)

func reset_scene() -> void:
	print("Reset scene")
	for child in get_children():
		if child is Enemy:
			child.reset()
