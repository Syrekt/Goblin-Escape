extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)


func _on_stab_hitbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_slash_hitbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
