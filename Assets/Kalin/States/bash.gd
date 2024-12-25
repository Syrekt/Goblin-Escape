extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("bash")

func physics_update(delta: float) -> void:
	if player.animation_player.frame == 3:
		player.velocity.x = 150 * player.facing
	player.move(delta)

func update(delta):
	if not player.is_on_floor():
		finished.emit("fall")
