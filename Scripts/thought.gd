extends HBoxContainer

var tween : Tween
@onready var label : RichTextLabel = find_child("Thought")

func tween_reset() -> void:
	if tween:
		modulate.a = 1.0
		tween.kill()

	tween = create_tween().bind_node(self)
	tween.tween_property(self, "modulate:a", 0.0, 6)
	tween.tween_callback(queue_free)

func _ready() -> void:
	tween_reset()
