extends Node2D

var amount_cur := 0.0
var amount_max : float
var is_ready := false
var source : CharacterBody2D

@onready var collider = $Area2D
@onready var shape = $Area2D/Shape


func _process(delta: float) -> void:
	if !is_ready:
		await get_tree().process_frame
		is_ready = true
		return

	amount_cur = move_toward(amount_cur, amount_max, 0.3 * 60 * delta)
	if amount_cur >= amount_max:
		queue_free()
	shape.scale = Vector2(amount_cur, amount_cur)
	queue_redraw()

	if collider.has_overlapping_bodies():
		for body in collider.get_overlapping_bodies():
			if body is Enemy:
				body.hear_noise(self)



func _draw() -> void:
	draw_circle(Vector2.ZERO, 10*amount_cur, Color(1, 1, 1, 0.2), false)
