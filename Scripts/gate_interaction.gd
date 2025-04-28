extends Interaction


func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		if player.inventory_panel.inventory.has_item(owner.key):
			player.inventory_panel.inventory.item_reduce(owner.key)
			owner.closed = false
