extends Area2D

@export_multiline var thougth : String


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.think(thougth)
		save()
		queue_free()


func save() -> void:
	var node_data = {
		"destroyed" : true
	}
	Ge.save_node(self, node_data)
func load(data: Dictionary) -> void:
	if data.destroyed:
		queue_free()
