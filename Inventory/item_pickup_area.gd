extends Area2D

var auto := false
var repeat := false
var title : String ## Text that shows besides the button prompt

var active := false
var waiting_player_exit := false

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.inventory_panel.inventory.item_add(owner.item)
		var text = "[img]" + owner.texture.resource_path + "[/img]" + owner.item.name
		Ge.popup_text(player.global_position, text)
		Ge.play_audio_free(0, owner.pickup_sound)
		owner.queue_free()
