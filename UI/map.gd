## Due to the way that Container nodes handle their children, at _ready() time you won’t get the correct value 
## for the child’s size. For this reason, we need to wait until the next frame to get the Grid’s size. 
class_name Map extends CanvasLayer

var teleporting := false
var portal_nodes	: Array[Portal]
var portal_from		: Portal
var portal_target	: Portal

var player : Player
@onready var camera	= $MapContainer/MarginContainer/SubViewportContainer/SubViewport/Camera2D
@onready var zoom	= camera.zoom.x:
	set = set_zoom
func set_zoom(value):
	var old_zoom = zoom
	zoom = clamp(value, 0.1, 5)
	if zoom != old_zoom:
		camera.zoom = Vector2(zoom, zoom)

@onready var grid			= $MapContainer/MarginContainer/Grid
@onready var player_marker	= $MapContainer/MarginContainer/SubViewportContainer/SubViewport/PlayerMarker
@onready var enemy_marker	= $MapContainer/MarginContainer/SubViewportContainer/SubViewport/EnemyMarker
@onready var portal_marker	= $MapContainer/MarginContainer/SubViewportContainer/SubViewport/PortalMarker

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
		var new_marker = icons[node.map_icon].duplicate()
		grid.add_child(new_marker)
		new_marker.show()
		markers[node] = new_marker

	# Add portals to list
	for node in get_tree().current_scene.get_children():
		if node is Portal && !node.inert:
			portal_nodes.append(node)

func _process(delta: float) -> void:
	# Check for player and adjust position
	if !player:
		player = Ge.player
		camera.global_position = player.global_position - $MapContainer.get_viewport_rect().size / 2
		return
	if teleporting:
		camera.global_position = portal_target.global_position - $MapContainer.get_viewport_rect().size / 2 #lerp(camera.global_position, portal_target.global_position - $MapContainer.get_viewport_rect().size / 2, 0.05)
	# Zoom
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
	# Teleport to active portals
	if teleporting:
		if Input.is_action_just_pressed("left"):
			var index = portal_nodes.find(portal_target)
			if index > 0:
				portal_target = portal_nodes.get(index - 1)
		elif Input.is_action_just_pressed("right"):
			var index = portal_nodes.find(portal_target)
			if index < portal_nodes.size() - 1:
				portal_target = portal_nodes.get(index + 1)
		elif portal_target != portal_from && Input.is_action_just_pressed("interact"):
			visible = false
			var fade = get_tree().current_scene.get_node("ScreenFade")
			player.controls_disabled = true
			fade.fade_in(1.0)
			await get_tree().create_timer(1.0).timeout
			player.global_position = portal_target.global_position
			fade.fade_out(1.0)
			player.controls_disabled = false
			queue_free()
			return
	# Dragging is disabled while teleporting
	if dragging:
		drag()
#region Drag
func drag_start() -> void:
	dragging = true
	mouse_pos_start = $MapContainer.get_viewport().get_mouse_position()
func drag() -> void:
	var mouse_pos = $MapContainer.get_viewport().get_mouse_position()
	camera_offset = (mouse_pos_start - mouse_pos) / camera.zoom
	camera.offset = camera_offset
func drag_end() -> void:
	dragging = false
	camera.offset = Vector2(0, 0)
	camera.global_position += camera_offset
#endregion
func _on_map_container_gui_input(event: InputEvent) -> void:
	# Close map
	if Input.is_action_just_pressed("ui_cancel"):
		print("close map")
		queue_free()
		return
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
