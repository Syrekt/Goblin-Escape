extends Camera2D

@onready var goblin_marker : Sprite2D = $GoblinMarker
@onready var goblin_warrior_marker : Sprite2D = $GoblinWarriorMarker

@onready var icons = {
	"goblin" : goblin_marker,
	"goblin_warrior" : goblin_warrior_marker,
}
var markers = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	var game = Game.get_singleton()
	game.room_loaded.connect(_on_room_load)

func _on_room_load() -> void:
	for marker in markers:
		marker.queue_free()
	var game = Game.get_singleton()
	for child in game.map.get_children():
		if child is Enemy:
			var new_marker = icons[child.map_icon].duplicate()
			add_child(new_marker)
			markers[child] = new_marker
	print("markers: "+str(markers))






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var game = Game.get_singleton()
	var viewport_rect = Rect2(
		get_screen_center_position() - get_viewport_rect().size / 2 / zoom,
		get_viewport_rect().size / zoom
	)
	var tilemap = game.map.get_node("Tilemaps/BG-2-Wall-Doors-Windows")
	var tile_size = tilemap.tile_set.tile_size
	var map_size = tilemap.get_used_rect().size
	var room_size = Vector2(map_size * tile_size)
	var padding = 10;
	
	for node in markers:
		if !node:
			markers[node].queue_free()
			markers.erase(node)
	for node in markers:
		var enemy_in_view = viewport_rect.has_point(node.global_position)
		if enemy_in_view:
			markers[node].hide()
			continue
		markers[node].show()
		if node.aware:
			markers[node].material.set_shader_parameter("outline_color", Color(1, 0, 0, 1))
		else:
			markers[node].material.set_shader_parameter("outline_color", Color(1, 1, 1, 1))
		markers[node].position = node.global_position - game.player.pcam.global_position
		markers[node].position.x = clamp(markers[node].position.x, -viewport_rect.size.x/2 + padding, viewport_rect.size.x/2 - padding)
		markers[node].position.y = clamp(markers[node].position.y, -viewport_rect.size.y/2 + padding, viewport_rect.size.y/2 - padding)
