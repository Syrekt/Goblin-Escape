extends Interaction

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		owner.toggle_light()
