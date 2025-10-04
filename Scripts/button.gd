extends Button

var pos_y : float = position.y

var mouse_down := false
var hovering := false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _process(delta: float) -> void:
	if mouse_down:
		position.y = pos_y + 1
	elif hovering:
		position.y = pos_y - 1
	else:
		position.y = pos_y

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false

func _on_button_down() -> void:
	mouse_down = true

func _on_button_up() -> void:
	mouse_down = false

