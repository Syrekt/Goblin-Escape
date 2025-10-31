extends Interaction

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.inventory_panel.inventory.item_add(owner.item)
		var text = "[img]" + owner.texture.resource_path + "[/img]" + owner.item.name
		Ge.popup_text(player.global_position, text)
		Ge.play_audio_free(0, owner.pickup_sound)
		owner.queue_free()
