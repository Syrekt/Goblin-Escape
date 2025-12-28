extends Interaction

@export var tutorial : PackedScene

func _enter_tree() -> void:
	if Game.get_singleton().get_data_in_room(name):
		queue_free()

func activate() -> void:
	if !Ge.show_tutorials:
		print("Tutorials are disabled, skipping")
		return

	if active:
		print("Activating dialogue while it's already active!")

	active = true;
	print("Activate tutorial")

	var node = tutorial.instantiate()
	get_tree().current_scene.add_child(node)

	queue_free()

	Game.get_singleton().save_data_in_room(name, {"destroyed": true})


func update(player : Player) -> void:
	if auto:
		if !active && !waiting_player_exit:
			waiting_player_exit = true
			activate()
	else:
		if !active && Input.is_action_just_pressed("interact"):
			activate()
			player.tutorial_sfx.play()
