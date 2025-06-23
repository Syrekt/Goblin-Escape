extends EnemyState

@onready var timer : Timer = $Timer

func enter(previous_state_path: String, data := {}):
	enemy.call_deferred("update_animation", "idle")
	enemy.emote_emitter.play("smell")
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	enemy.velocity.x = 0

func exit() -> void:
	timer.stop()

func _on_timer_timeout() -> void:
	finished.emit("triggered")
