extends Interaction

var amount : int

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.experience.add(amount)
		queue_free()
