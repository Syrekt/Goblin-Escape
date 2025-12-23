extends Interaction

@onready var sfx_emitter : FmodEventEmitter2D = $SFXEmitter

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.inventory_panel.inventory.item_add(owner.item)
		var text = "[img]" + owner.texture.resource_path + "[/img]" + owner.item.item_name
		Ge.popup_text(player.global_position, text)
		sfx_emitter.play()
		# Save item pickup
		if !owner.instantiated:
			Game.get_singleton().save_data_in_room(owner.name, { "picked": true })
		owner.queue_free()
