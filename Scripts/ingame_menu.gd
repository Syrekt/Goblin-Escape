extends MainMenu


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = false;
		queue_free()

func _on_continue_button_up() -> void:
	get_tree().paused = false;
	queue_free()
