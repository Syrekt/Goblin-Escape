extends PlayerState

@onready var timer = $Timer

func enter(previous_state_path: String, data := {}) -> void:
	player.direction_locked = true
	player.animation_player.call_deferred("play", "fall")
	timer.start(0.3)

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		if timer.is_stopped():
			finished.emit("land")
		else:
			finished.emit("idle")
			player.direction_locked = false

	if player.can_grab_corner():
		finished.emit("corner_grab")
