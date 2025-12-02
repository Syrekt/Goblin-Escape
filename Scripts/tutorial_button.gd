extends Button

@export var tutorial_scene	: PackedScene
@export var tutorial_code	: String

@onready var tutorial_info : RichTextLabel = $"../../../TutorialInfo"

func _ready() -> void:
	var tutorial_seen = Game.get_singleton().persistent_values.get("Tutorial-" + tutorial_code, false)
	if !tutorial_seen:
		hide()
	else:
		pressed.connect(owner._on_tutorial_button_pressed.bind(tutorial_scene))
		tutorial_info.hide()
