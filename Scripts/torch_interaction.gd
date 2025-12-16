extends Interaction

func update(player: Player) -> void:
	if player && player.just_pressed("interact"):
		owner.toggle_light()
