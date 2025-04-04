extends PlayerState

@onready var recovery_timer = $RecoveryTimer

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	recovery_timer.start()


func update(delta: float) -> void:
	if recovery_timer.is_stopped():
		finished.emit("recover")
