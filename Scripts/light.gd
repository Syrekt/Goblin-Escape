extends Area2D

func _on_body_entered(body: Player) -> void:
	body.light_source = self

func _on_body_exited(body: Player) -> void:
	if body.light_source == self:
		body.light_source = null
