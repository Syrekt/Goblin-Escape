extends PlayerState

var just_entered := false

func enter(previous_path_string: String, data := {}) -> void:
	#player.position.x += player.facing*player.climb_xoff
	player.position.y += player.climb_yoff
	player.animation_player.call_deferred("play", "corner_grab")
	just_entered = true

func physics_update(delta: float) -> void:
	if just_entered:
		while !player.is_on_wall():
			print("player.x += player.facing")
			player.position.x += player.facing
			player.velocity.y = 0;
			player.move_and_slide()
		while player.is_on_wall():
			print("player.x -= player.facing")
			player.position.x -= player.facing
			player.velocity.y = 0;
			player.move_and_slide()
		player.position.x -= 4*player.facing
	just_entered = false


func update(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		finished.emit("corner_climb")
	if Input.is_action_just_pressed("down"):
		player.ignore_corners = true;
		finished.emit("fall")
