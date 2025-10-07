## Due to the way that Container nodes handle their children, at _ready() time you won’t get the correct value 
## for the child’s size. For this reason, we need to wait until the next frame to get the Grid’s size. 
class_name Map extends MarginContainer

var player : Player
@export var zoom = 1.5:
	set = set_zoom

func set_zoom(value):
	var old_zoom = zoom
	zoom = clamp(value, 0.1, 0.5)
	if zoom != old_zoom:
		camera.zoom = Vector2(zoom, zoom)

@onready var camera			= $MarginContainer/SubViewportContainer/SubViewport/Camera2D
@onready var grid			= $MarginContainer/Grid
@onready var player_marker	= $MarginContainer/Grid/PlayerMarker
@onready var enemy_marker	= $MarginContainer/Grid/EnemyMarker
@onready var portal_marker	= $MarginContainer/Grid/PortalMarker

@onready var icons = {
	"player": player_marker,
	"enemy"	: enemy_marker,
	"portal": portal_marker,
}

var grid_scale
var markers = {}

var dragging := false
var camera_offset := Vector2(0, 0)
var mouse_pos_start : Vector2

func _ready() -> void:
	player = Ge.player
	# In _ready() we’ll center the player’s marker at the center of the grid. and calculate the scale factor. 
	# (Note: you’ll need to connect the resized signal and do both of these things in the callback if you have 
	# a dynamically sized UI).
	await get_tree().process_frame
	player_marker.position = grid.size / 2
	grid_scale = grid.size / (get_viewport_rect().size * zoom)
	
	# We’ll also create markers for every game object (using the “minimap_objects” group) by duplicating 
	# the matching marker node and tying the marker to the object via the markers dictionary: 
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
		return

	# Next, we’ll find each object’s position relative to the player and use that to find the marker’s position 
	# (remembering to offset by grid.size / 2 because the control’s origin is in the top left corner). 
	for node in markers:
		var node_pos = (node.position - player.position) * grid_scale + grid.size / 2
		# We can also decide what to do about markers that are “off-screen” - when they would be outside the
		# grid’s rectangle. Choose one of the following options (do this also before using clamp()).
		# The first option is to hide them:
		if grid.get_rect().has_point(node_pos + grid.position):
			markers[node].show()
		else:
			markers[node].hide()


		# The problem with this is that markers can be placed outside the grid:
		# To fix this, after calculating obj_pos, but before setting the marker’s position, 
		# clamp it to the grid’s rectangle:
		node_pos = node_pos.clamp(Vector2.ZERO, grid.size)

		markers[node].position = node_pos

	if dragging: drag()
	Debugger.printui("camera.zoom: "+str(camera.zoom));
	Debugger.printui("camera.position: "+str(camera.position));

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


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom += 0.1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom -= 0.1
			elif event.button_index == MOUSE_BUTTON_LEFT:
				drag_start()
		elif dragging:
			drag_end()
