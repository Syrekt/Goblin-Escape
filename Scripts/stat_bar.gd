class_name StatBar extends TextureProgressBar

var buff_scene = preload("res://Objects/buff.tscn")

@export var buff_sprite : Texture2D
@export var debuff_sprite : Texture2D

@onready var buff_container = owner.find_child("BuffContainer")

var tween_tint		: Tween
var tween_sprite	: Tween

func add_buff(_value : float, _time : float) -> void:
	var buff = buff_scene.instantiate()
	if _value < 0:
		buff.texture = debuff_sprite
	buff_container.add_child(buff)
	buff.setup(_value, _time)

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
