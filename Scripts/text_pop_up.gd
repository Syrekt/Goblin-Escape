extends Node2D

@export var yspeed := 20.0

@onready var label : RichTextLabel = $Label

func tween_begin(color1: Color, color2: Color) -> void:
	var tween = create_tween().bind_node(self)
	tween.tween_property(label, "modulate", color1, 0.1)
	tween.tween_property(label, "modulate", color2, 0.1)
	tween.tween_property(label, "modulate", color1, 0.1)
	tween.tween_property(label, "modulate", color2, 0.1)
	tween.tween_property(label, "modulate:a", 0.0, 2)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	global_position.y -= yspeed * delta
