extends MainMenu

var prevent_closing := false
var skip_first_event := true


func _process(delta: float) -> void:
	if !prevent_closing && Input.is_action_just_pressed("ui_cancel"):
		if skip_first_event: skip_first_event = false
		else:
			get_tree().paused = false;
			queue_free()

func _on_continue_button_up() -> void:
	get_tree().paused = false;
	queue_free()
