extends Area2D

@export var damage : int


func _enter_tree() -> void:
	get_tree().create_timer(1.0).timeout.connect(_activate)


func _activate() -> void:
	monitoring	= true
	monitorable = true

func _on_body_entered(body:Node2D) -> void:
	if body is Player:
		body.enter_abyss.emit(self)
	elif body is Enemy:
		body.state_node.state.finished.emit("death")
		body.queue_free()

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_K):
		for child in get_children():
			print(child.name)
