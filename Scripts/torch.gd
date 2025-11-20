extends Area2D

var ray : RayCast2D

@export var lit := true
@export var toggle_speed := 1.0

@onready var lit_area : CollisionShape2D = $LitArea
@onready var point_light : PointLight2D = $PointLight2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if !lit:
		lit_area.scale = Vector2(0, 0)
		point_light.scale = Vector2(0, 0)
		sprite.play("unlit")
	ray = RayCast2D.new()
	ray.collide_with_areas = true
	add_child(ray)


func toggle_light() -> void:
	var tween_light = create_tween().bind_node(self)
	var tween_area = create_tween().bind_node(self)
	if lit:
		tween_area.tween_property(lit_area, "scale", Vector2(0, 0), toggle_speed)
		tween_light.tween_property(point_light, "scale", Vector2(0, 0), toggle_speed)
		lit = false
		sprite.play("unlit")
	else:
		tween_area.tween_property(lit_area, "scale", Vector2(1, 1), toggle_speed)
		tween_light.tween_property(point_light, "scale", Vector2(80, 80), toggle_speed)
		lit = true
		sprite.play("lit")
	save()


func save() -> void:
	Game.get_singleton().save_data_in_room(name, { "lit": lit, })

func load() -> void:
	var save_data = Game.get_singleton().get_data_in_room(name)
	if save_data:
		lit = save_data.get("lit", lit)
		if !lit:
			lit_area.scale = Vector2(0, 0)
			point_light.scale = Vector2(0, 0)
			sprite.play("unlit")


func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player || body is Enemy:
		ray.target_position = ray.to_local(body.global_position)
		await get_tree().physics_frame
		if(!ray.is_colliding()):
			body.light_source = self

func _on_body_exited(body: CharacterBody2D) -> void:
	if body is Player || body is Enemy:
		if body.light_source == self:
			body.light_source = null
