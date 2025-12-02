extends Button

@export var tutorial_scene : PackedScene

@onready var options_menu = $"../../../.."

func _ready() -> void:
	pressed.connect(options_menu._on_tutorial_button_pressed.bind(tutorial_scene))
