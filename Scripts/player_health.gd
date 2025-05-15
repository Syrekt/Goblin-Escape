extends TextureProgressBar

@export var regeneration_speed := 0.01

var buff_scene = preload("res://Objects/buff.tscn")
var tween : Tween = null
var tint_under_tween : Tween = null

func _process(delta: float) -> void:
	var final_regeneration_speed = regeneration_speed

	value += final_regeneration_speed * delta

	if final_regeneration_speed > regeneration_speed:
		if !tint_under_tween:
			tint_under_tween = create_tween().bind_node(self)
			tint_under_tween.set_loops(-1)
			tint_under_tween.tween_property(self, "tint_under", Color.GREEN, 1.0)
			tint_under_tween.tween_property(self, "tint_under", Color.WHITE, 1.0)
	elif tint_under_tween:
		tint_under_tween.kill()
		tint_under_tween = null

func blink() -> void:
	if tween && tween.is_running(): return 

	tween = create_tween().bind_node(self)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color.RED, 0.1)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color(0, 0, 0, 0), 0.1)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color.RED, 0.1)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color(0, 0, 0, 0), 0.1)

	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func add_buff(_value : float, _time : float) -> void:
	var buff = buff_scene.instantiate()
	add_child(buff)
	buff.setup(_value, _time)
