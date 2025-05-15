extends CanvasLayer

func _ready() -> void:
	$Page1.show()
	$Page2.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("stance"):
		if $Page1.visible:
			$Page1.hide()
			$Page2.show()
		elif $Page2.visible:
			queue_free()
