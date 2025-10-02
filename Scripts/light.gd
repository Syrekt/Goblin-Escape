extends Area2D


@export var lit := true
@export var toggle_speed := 1.0

@onready var lit_area : CollisionShape2D = $LitArea
@onready var point_ligth : PointLight2D = $PointLight2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if !lit:
		lit_area.scale = Vector2(0, 0)
		point_ligth.scale = Vector2(0, 0)


func toggle_ligth() -> void:
	var tween_ligth = create_tween().bind_node(self)
	var tween_area = create_tween().bind_node(self)
	if lit:
		tween_area.tween_property(lit_area, "scale", Vector2(0, 0), toggle_speed)
		tween_ligth.tween_property(point_ligth, "scale", Vector2(0, 0), toggle_speed)
		lit = false
		sprite.play("unlit")
	else:
		tween_area.tween_property(lit_area, "scale", Vector2(1, 1), toggle_speed)
		tween_ligth.tween_property(point_ligth, "scale", Vector2(80, 80), toggle_speed)
		lit = true
		sprite.play("lit")


func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player || body is Enemy:
		body.light_source = self

func _on_body_exited(body: CharacterBody2D) -> void:
	if body is Player || body is Enemy:
		if body.light_source == self:
			body.light_source = null
