extends Interaction

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		if player.inventory_panel.inventory.has_item(owner.key):
			player.inventory_panel.inventory.item_reduce(owner.key)
			owner.closed = false
		else:
			if owner.closed_dialogue != "":
				Ge.one_shot_dialogue(owner.closed_dialogue)
			elif owner.custom_thought != "":
				player.think(owner.custom_thought)
			else:
				player.think(["I need a key", "It's locked"].pick_random())
