extends TextureProgressBar

#var tint_tween : Tween
#
#func _ready() -> void:
#	pass
#
#func _process(delta: float) -> void:
#	if owner.chase_target:
#		visible = true
#	else:
#		visible = false
#
#func take_damage() -> void:
#	if tint_tween:
#		tint_tween.kill()
#
#	tint_tween = create_tween().bind_node(self)
#
#	tint_tween.tween_property(self, "tint_under", Color.YELLOW, 0.1)
#	tint_tween.tween_property(self, "tint_under", Color.WHITE, 0.1)
#	tint_tween.tween_property(self, "tint_under", Color.YELLOW, 0.1)
#	tint_tween.tween_property(self, "tint_under", Color.WHITE, 0.1)
