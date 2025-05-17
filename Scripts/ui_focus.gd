extends ColorRect

var tween : Tween

@export var transparency := 0.2

func fade_in() -> void:
	show()
	tween = create_tween().bind_node(self)
	tween.tween_property(self, "color", Color(0, 0, 0, transparency), 0.2)
func fade_out() -> void:
	if tween:
		tween.kill()
	tween = create_tween().bind_node(self)
	tween.tween_property(self, "color", Color(0, 0, 0, 0), 0.2)
	tween.tween_callback(hide)
