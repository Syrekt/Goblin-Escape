extends Interaction

@export var tutorial : PackedScene

func activate() -> void:
	if active:
		print("Activating dialogue while it's already active!")

	active = true;
	print("Activate tutorial")

	var node = tutorial.instantiate()
	get_tree().current_scene.add_child(node)

	queue_free()


func update(player : Player) -> void:
	if auto:
		if !active && !waiting_player_exit:
			waiting_player_exit = true
			activate()
	else:
		if !active && Input.is_action_just_pressed("interact"):
			activate()
