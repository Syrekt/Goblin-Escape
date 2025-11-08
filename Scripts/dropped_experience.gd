extends Interaction

var amount : int

func _ready() -> void:
	var game = Game.get_singleton()
	game.dropped_exp = {
		"room": game.map.name,
		"name": name,
		"amount": amount,
		"pos_x": position.x,
		"pos_y": position.y,
	}


func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.experience.add(amount)
		queue_free()
