extends Node2D

@onready var collider_collision : CollisionShape2D = $Platform/CollisionShape2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		collider_collision.set_deferred("one_way_collision", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		collider_collision.set_deferred("one_way_collision", false)
