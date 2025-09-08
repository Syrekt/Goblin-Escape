extends CanvasLayer

@onready var modulator : CanvasModulate = $CanvasModulate

func fade_in(time := 1.0) -> void:
	var tween_ui = create_tween().bind_node(self)
	tween_ui.tween_property(modulator, "color", Color(1.0, 1.0, 1.0, 1.0), time)

func fade_out(time := 1.0) -> void:
	var tween_ui = create_tween().bind_node(self)
	tween_ui.tween_property(modulator, "color", Color(1.0, 1.0, 1.0, 0.0), time)
