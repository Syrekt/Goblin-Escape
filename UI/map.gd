## Due to the way that Container nodes handle their children, at _ready() time you won’t get the correct value 
## for the child’s size. For this reason, we need to wait until the next frame to get the Grid’s size. 
class_name Map extends MarginContainer

var player : Player
@onready var camera			= $MarginContainer/SubViewportContainer/SubViewport/Camera2D
@onready var zoom = camera.zoom.x:
	set = set_zoom
func set_zoom(value):
	var old_zoom = zoom
	zoom = clamp(value, 0.1, 5)
	if zoom != old_zoom:
		camera.zoom = Vector2(zoom, zoom)

@onready var grid			= $MarginContainer/Grid
@onready var player_marker	= $MarginContainer/SubViewportContainer/SubViewport/PlayerMarker
@onready var enemy_marker	= $MarginContainer/SubViewportContainer/SubViewport/EnemyMarker
@onready var portal_marker	= $MarginContainer/SubViewportContainer/SubViewport/PortalMarker

@onready var icons = {
	"player": player_marker,
	"enemy"	: enemy_marker,
	"portal": portal_marker,
}

var markers = {}

var dragging := false
var camera_offset := Vector2(0, 0)
var mouse_pos_start : Vector2

func _ready() -> void:
	player = Ge.player
	
	var map_nodes = get_tree().get_nodes_in_group("MapNode")
	for node in map_nodes:
		print("node: "+str(node))
		var new_marker = icons[node.map_icon].duplicate()
		grid.add_child(new_marker)
		new_marker.show()
		markers[node] = new_marker

func _process(delta: float) -> void:
	if !player:
		player = Ge.player
		camera.global_position = player.global_position - get_viewport_rect().size / 2
		return

	var screen_rect = Rect2(
		camera.get_screen_center_position() - camera.get_viewport_rect().size * 0.5 / camera.zoom,
		camera.get_viewport_rect().size / camera.zoom
	)
	# Remove any freed nodes from array
	for node in markers:
		if !node:
			markers.erase(node)
	for node in markers:
		markers[node].position = (node.global_position - screen_rect.position) * camera.zoom 
		if node == player:
			markers[node].position.x = clamp(markers[node].position.x, 0, screen_rect.size.x * camera.zoom.x)
			markers[node].position.y = clamp(markers[node].position.y, 0, screen_rect.size.y * camera.zoom.y)
		if screen_rect.has_point(node.global_position):
			markers[node].show()
		elif node != player:
			markers[node].hide()

	if dragging: drag()

#region Drag
func drag_start() -> void:
	dragging = true
	mouse_pos_start = get_viewport().get_mouse_position()
func drag() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	camera_offset = (mouse_pos_start - mouse_pos) / camera.zoom
	camera.offset = camera_offset
func drag_end() -> void:
	dragging = false
	camera.offset = Vector2(0, 0)
	camera.global_position += camera_offset
#endregion
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom += 0.1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom -= 0.1
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				drag_start()
		elif dragging:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				drag_end()
