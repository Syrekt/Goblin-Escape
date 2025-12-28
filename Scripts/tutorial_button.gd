extends Button

@export var tutorial_scene	: PackedScene
@export var tutorial_code	: String

@onready var tutorial_info : RichTextLabel = $"../../../TutorialInfo"

var tutorial_seen := false

func _ready() -> void:
	tutorial_seen = Game.get_singleton().persistent_values.get("Tutorial-" + tutorial_code, false)
	pressed.connect(owner._on_tutorial_button_pressed.bind(tutorial_scene))

func _process(delta: float) -> void:
	if !Ge.show_tutorials: ## Enable every tutorial if tutorials are disabled by player
		show()
		tutorial_info.hide()
	else: ## Otherwise, only show unlocked options
		if !tutorial_seen:
			hide()
			tutorial_info.show()
		else:
			tutorial_info.hide()
