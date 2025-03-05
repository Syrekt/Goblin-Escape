extends PlayerState

@onready var timer = $Timer

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "fall")
	timer.start(0.3)

func physics_update(delta: float) -> void:
	player.fall(delta)
	if player.is_on_floor():
		if timer.is_stopped():
			finished.emit("land")
		else:
			finished.emit("idle")

	if !player.ignore_corners && player.ray_corner_check.is_colliding() && !player.ray_corner_prevent.is_colliding():
		finished.emit("corner_grab")
