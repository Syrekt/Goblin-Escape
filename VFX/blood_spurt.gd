extends GPUParticles2D

func _on_finished() -> void:
	print("blood spurt/gush ended")
	queue_free()
