extends Area2D

@export_multiline var thougth : String


func _ready() -> void:
	if Game.get_singleton().get_data_in_room(name):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.think(thougth)
		Game.get_singleton().save_data_in_room(name, {"destroyed":true})
		queue_free()
