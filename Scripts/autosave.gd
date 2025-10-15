extends Area2D




func _on_body_entered(body:Node2D) -> void:
	Ge.save_game()
	queue_free()
