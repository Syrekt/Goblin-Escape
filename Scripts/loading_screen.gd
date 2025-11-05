class_name LoadingScreen extends CanvasLayer


func tween_in() -> void:
	show()
	# Decided to remove the font anyway
	var tween_font = create_tween().bind_node(self)
	var font = find_child("Label")
	font.set("theme_override_colors/font_color", Color.WHITE)
	tween_font.tween_property(font, "theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 0.0), 0.5)

	var tween_rect = create_tween().bind_node(self).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	var rect = find_child("ColorRect")
	rect.color = Color.BLACK
	tween_rect.tween_property(rect, "color", Color(0.0, 0.0, 0.0, 0.0), 2)
	tween_rect.tween_callback(hide)
