class_name IngameMenu extends CanvasLayer


var skip_first_event := true

@onready var close_button : Button = $Close


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape_menu") || Input.is_action_just_pressed("ui_cancel"):
		if skip_first_event: skip_first_event = false
		else:
			get_tree().paused = false;
			queue_free()
	skip_first_event = false

func _on_close_pressed() -> void:
	get_tree().paused = false;
	queue_free()
