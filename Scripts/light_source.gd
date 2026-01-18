extends PointLight2D

@onready var ray : RayCast2D = $LightSource/RayCast2D
@onready var lit_area : CollisionShape2D = $LightSource/LitArea
@onready var point_light : PointLight2D = self
@onready var light_source: Area2D = $LightSource

@export var lit := true

var player : Player

func _on_light_source_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
	if body is Player || body is Enemy:
		ray.target_position = ray.to_local(body.global_position)
		await get_tree().physics_frame
		if(!ray.is_colliding()):
			body.light_source = light_source


func _on_light_source_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
	if body is Player || body is Enemy:
		if body.light_source == light_source:
			body.light_source = null
