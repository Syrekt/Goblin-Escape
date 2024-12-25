extends Area2D

@onready var manager = %GameManager

func _on_body_entered(body):
	manager.add_point()
	queue_free()
