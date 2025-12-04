extends MainMenu

var skip_first_event := true


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if skip_first_event: skip_first_event = false
		else:
			get_tree().paused = false;
			queue_free()
	skip_first_event = false

func _on_continue_button_up() -> void:
	get_tree().paused = false;
	queue_free()
