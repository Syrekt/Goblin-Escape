extends Interaction

var experience_amount : int

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.experience.value += experience_amount
		queue_free()
