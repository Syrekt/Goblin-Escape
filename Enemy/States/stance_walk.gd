extends EnemyState

var timer : Timer
var direction : int

func enter(previous_state_path: String, data := {"time": 0, "reverse" : false}) -> void:
	enemy.direction_locked = true
	if data.reverse:
		enemy.call_deferred("update_animation", "run", -1)
	else:
		enemy.call_deferred("update_animation", "run")
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start(data.time)

	direction = -enemy.facing if data.reverse else enemy.facing

func exit() -> void:
	enemy.direction_locked = false


func update(delta: float) -> void:
	enemy.move(enemy.move_speed, direction)
	Debugger.printui("enemy.velocity: "+str(enemy.velocity));

func _on_timer_timeout() -> void:
	finished.emit("stance_light")
