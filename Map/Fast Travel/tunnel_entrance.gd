class_name TunnelEntrance extends Interaction

@export var target_entrance : TunnelEntrance


func update(player: Player) -> void:
	if Input.is_action_pressed("interact"):
		player.global_position = target_entrance.global_position
		player.col_interaction.interact()
