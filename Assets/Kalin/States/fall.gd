extends PlayerState

@onready var timer = $Timer

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "fall")
	timer.start(0.3)

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		if timer.is_stopped():
			finished.emit("land")
		else:
			finished.emit("idle")

	if player.can_grab_corner() && player.ray_corner_grab_check.is_colliding():
		finished.emit("corner_grab")
