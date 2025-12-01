extends CanvasLayer


func _on_yes_pressed() -> void:
	var player = Game.get_singleton().player

	player.take_damage(player.health.max_value)
	queue_free()


func _on_no_pressed() -> void:
	queue_free()
