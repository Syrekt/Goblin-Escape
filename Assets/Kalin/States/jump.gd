extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = -player.jump_impulse
	player.animation_player.play("rise")

func physics_update(delta: float) -> void:
	player.fall(delta);

func update(delta):
	if player.velocity.y >= 0:
		finished.emit("fall")
