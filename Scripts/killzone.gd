extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	print("You died!")
	Engine.time_scale = 0.5
	timer.start()
	body.get_node("Collider").queue_free()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
