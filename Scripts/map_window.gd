# The window that contains a bigger map overview than minimap. Toggled with M.
extends Panel

@onready var player: CharacterBody2D = %Kalin
@onready var minimap: Control = %Minimap
@onready var top_draw: Control = $TopDraw

# The size of the window in cells.
var SIZE: Vector2i

# MapView object that draws cells.
var map_view: MapView

# The position where the player started (for the vector feature).
var starting_coords: Vector2i
# The player location node from MetSys.add_player_location()
var player_location: Node2D
# The vector feature, toggled with D. It displays an arrow from player's starting point to the current position.
# It's purely to show custom drawing on the map.
var show_delta: bool
# The offset for drawing delta vector, updated with map panning.
var offset: Vector2i

func _ready() -> void:
	# Cellular size is total size divided by cell size.
	SIZE = size / MetSys.CELL_SIZE
	map_view = MetSys.make_map_view(self, -SIZE / 2, SIZE, 0)
	
	# Create player location. We need a reference to update its offset.
	player_location = MetSys.add_player_location(self)

# Draws the delta vector. Note that TopDraw node is used, to make sure that it appears above cells.
func _on_top_draw() -> void:
	# Get the current player coordinates.
	var coords := MetSys.get_current_flat_coords()
	# If the delta vector (D) is enabled and player isn't on the starting position...
	if show_delta and coords != starting_coords:
		var start_pos := MetSys.get_cell_position(starting_coords - offset)
		var current_pos := MetSys.get_cell_position(coords - offset)
		# draw the vector...
		top_draw.draw_line(start_pos, current_pos, Color.WHITE, 2)
		
		const arrow_size = 4
		# and arrow. This code shows how to draw custom stuff on the map outside the MetSys functions.
		top_draw.draw_set_transform(current_pos, start_pos.angle_to_point(current_pos), Vector2.ONE)
		top_draw.draw_primitive([Vector2(-arrow_size, -arrow_size), Vector2(arrow_size, 0), Vector2(-arrow_size, arrow_size)], [Color.WHITE], [])

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			# Toggle visibility when pressing M.
			if event.keycode == KEY_M:
				visible = not visible
				# minimap.visible = not visible # Make minimap invisible when full map is visible.
				
				if visible:
					# Pause the player when opening map.
					player.process_mode = Node.PROCESS_MODE_DISABLED
					# Update map offset when opening it.
					update_offset()
				else:
					player.process_mode = Node.PROCESS_MODE_INHERIT
			#elif event.keycode == KEY_D:
			#	# D toggles position tracking (delta vector).
			#	show_delta = not show_delta
			#	top_draw.queue_redraw()
			elif visible:
				# Move with arrow keys.
				var move_offset: Vector2i
				if Input.is_action_just_pressed("left"):
					move_offset = Vector2i.LEFT
				elif Input.is_action_just_pressed("right"):
					move_offset = Vector2i.RIGHT
				elif Input.is_action_just_pressed("up"):
					move_offset = Vector2i.UP
				elif Input.is_action_just_pressed("down"):
					move_offset = Vector2i.DOWN
				
				# This moves the MapView's visible area, ensuring that only newly visible cells are redrawn.
				map_view.move(move_offset)
				# Player position node needs to be moved accordingly.
				player_location.offset = -Vector2(map_view.begin) * MetSys.CELL_SIZE
				# Update delta vector.
				offset += move_offset
				top_draw.queue_redraw()

# Assigns the initial offset when the map is opened. It centers on the player position.
func update_offset():
	offset = MetSys.get_current_flat_coords() - SIZE / 2
	# Player position node needs to be moved accordingly.
	player_location.offset = -Vector2(offset) * MetSys.CELL_SIZE
	# Updates map view initial position.
	map_view.move_to(Vector3i(offset.x, offset.y, MetSys.current_layer))
	# Update all cells of MapView to reflect the current state.
	map_view.update_all()

func reset_starting_coords():
	# Starting position for the delta vector.
	var coords := MetSys.get_current_flat_coords()
	starting_coords = Vector2i(coords.x, coords.y)
	top_draw.queue_redraw()
