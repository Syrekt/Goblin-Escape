class_name StatBar extends TextureProgressBar

var tween_tint		: Tween
var tween_sprite	: Tween

func blink(tint_kalin: Color, tint_sprite: Color) -> void:
	if tween_tint && tween_tint.is_running(): return 

	tween_tint = create_tween().bind_node(self)
	tween_sprite = create_tween().bind_node(self)

	tween_tint.tween_property(%Sprite2D.material, "shader_parameter/tint_color", tint_kalin, 0.1)
	tween_tint.tween_property(%Sprite2D.material, "shader_parameter/tint_color", owner.current_tint, 0.1)
	tween_tint.tween_property(%Sprite2D.material, "shader_parameter/tint_color", tint_kalin, 0.1)
	tween_tint.tween_property(%Sprite2D.material, "shader_parameter/tint_color", owner.current_tint, 0.1)

	tween_sprite.tween_property(self, "modulate", tint_sprite, 0.1)
	tween_sprite.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween_sprite.tween_property(self, "modulate", tint_sprite, 0.1)
	tween_sprite.tween_property(self, "modulate", Color.WHITE, 0.1)
