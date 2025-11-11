extends Node2D

var amount_cur := 0.0
var amount_max : float
var is_ready := false
var source : CharacterBody2D
var lifetime := 1.0
var tween_method = Tween.EASE_OUT
var color : Color


@onready var collider = $Area2D
@onready var shape = $Area2D/Shape

func _ready() -> void:
	color = Ge.noise_color

	var tween_scale = create_tween().bind_node(self)
	tween_scale.tween_property(shape, "scale", Vector2(amount_max, amount_max), lifetime).set_ease(tween_method)
	var tween_alpha = create_tween().bind_node(self)
	tween_alpha.tween_property(self, "color:a", 0, lifetime).set_ease(tween_method)
	tween_alpha.tween_callback(queue_free)

	z_index = 1

func _process(delta: float) -> void:
	if !is_ready:
		await get_tree().process_frame
		is_ready = true
		return

	#amount_cur = move_toward(amount_cur, amount_max, 0.3 * 60 * delta)
	#if amount_cur >= amount_max:
	#	queue_free()
	#shape.scale = Vector2(amount_cur, amount_cur)
	queue_redraw()

	if collider.has_overlapping_bodies():
		for body in collider.get_overlapping_bodies():
			if body is Enemy:
				body.hear_noise(self)



func _draw() -> void:
	if !Ge.noise_enabled || !Ge.show_noise_this_room: return
	draw_circle(Vector2.ZERO, 10*shape.scale.x, color, false)
