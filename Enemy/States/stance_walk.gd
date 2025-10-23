extends EnemyState

var timer : Timer
var direction : int
var facing : int

func enter(previous_state_path: String, data := {"time": 0, "backwards" : false}) -> void:
	if data.backwards:
		enemy.call_deferred("update_animation", "run", -1)
	else:
		enemy.call_deferred("update_animation", "run")

	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start(data.time)

	if data.backwards:
		facing		= enemy.facing
		direction	= -enemy.facing
	else:
		direction	= enemy.facing
		facing		= direction

func exit() -> void:
	timer.queue_free()

func update(delta: float) -> void:
	enemy.move(enemy.combat_move_speed, direction, facing)

func _on_timer_timeout() -> void:
	if !enemy.has_enemy_in_proximity():
		finished.emit("stance_light")
