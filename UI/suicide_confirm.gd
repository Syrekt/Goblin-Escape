extends CanvasLayer


func _ready() -> void:
	var icon_no = Ge.get_action_keycode("ui_cancel", true)
	var icon_yes = Ge.get_action_keycode("ui_accept", true)
	$Control/No.icon = load(icon_no)
	$Control/Yes.icon = load(icon_yes)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_on_yes_pressed()
	elif Input.is_action_just_pressed("ui_cancel"):
		_on_no_pressed()

func _on_yes_pressed() -> void:
	var player = Game.get_singleton().player

	player.take_damage(player.health.max_value)
	queue_free()


func _on_no_pressed() -> void:
	queue_free()
