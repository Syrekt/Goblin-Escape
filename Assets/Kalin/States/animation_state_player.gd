extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", name)


func _on_stab_hitbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_slash_hitbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
