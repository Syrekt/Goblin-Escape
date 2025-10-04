extends Area2D

@export var damage : int


func _on_body_entered(body:Node2D) -> void:
	if body is Player:
		body.enter_abyss.emit(self)
	elif body is Enemy:
		body.queue_free()
