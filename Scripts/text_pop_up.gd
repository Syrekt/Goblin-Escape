extends Node2D

@export var yspeed := 20.0

@onready var label : RichTextLabel = $Label

func _ready() -> void:
	var tween = create_tween().bind_node(self)
	tween.tween_property(label, "modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property(label, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.tween_property(label, "modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property(label, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.tween_property(label, "modulate:a", 0.0, 2)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	global_position.y -= yspeed * delta
