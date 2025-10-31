extends Interaction

func update(player: Player) -> void:
	interacted.emit()
	if Input.is_action_just_pressed("interact"):
		player.unlock_skill(owner.skill_name)
		owner.queue_free()
