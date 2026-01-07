class_name Hint extends Area2D

@export_multiline var text : String

@onready var label : RichTextLabel = $RichTextLabel
var text_tween : Tween


func _ready() -> void:
	label.text = text


func _on_body_entered(body: Node2D) -> void:
	if !Ge.show_hints: return

	if text_tween:
		text_tween.kill()
	text_tween = create_tween().bind_node(self)
	text_tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _on_body_exited(body: Node2D) -> void:
	if text_tween:
		text_tween.kill()
	text_tween = create_tween().bind_node(self)
	text_tween.tween_property(self, "modulate:a", 0.0, 1.0)
