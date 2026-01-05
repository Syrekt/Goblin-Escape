extends CanvasLayer


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		visible = !visible

func _on_hide_version_toggled(toggled_on: bool) -> void:
	%VersionNumber.visible = toggled_on
