extends Area2D

var player : CharacterBody2D = null


func _process(delta: float) -> void:
	Debugger.printui("player: "+str(player))
	if player:
		var player_state = player.state_node.state.name
		if player_state != "hiding" && player_state != "hidden" && player_state != "unhide":
			if Input.is_action_just_pressed("interact"):
				player.hide_out(self)

func _on_body_entered(body:Node2D) -> void:
	player = body

func _on_body_exited(body:Node2D) -> void:
	player = null
