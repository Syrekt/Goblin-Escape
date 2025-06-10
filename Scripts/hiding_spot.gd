extends Interaction

func update(player : Player) -> void:
	var player_state = player.state_node.state.name
	if player_state != "hiding" && player_state != "hidden" && player_state != "unhide":
		if Input.is_action_just_pressed("interact"):
			player.hide_out(self)
