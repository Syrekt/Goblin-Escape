extends PlayerState

func enter(previous_state_path:String, data := {}):
	player.call_deferred("update_animation", name)
	player.velocity.x = 0
