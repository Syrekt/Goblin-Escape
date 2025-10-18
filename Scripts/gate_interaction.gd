extends Interaction

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		if owner.closed_dialogue != "":
			Ge.one_shot_dialogue(owner.closed_dialogue)
		elif owner.custom_thought != "":
			player.think(owner.custom_thought)
		else:
			player.think(["Need to find a switch", "It's locked"].pick_random())
