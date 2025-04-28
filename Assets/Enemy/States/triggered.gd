extends EnemyState

@onready var ignore_timer : Timer = $IgnoreTimer
@onready var direction_timer : Timer = $DirectionTimer

func enter(previous_state_path : String, data = {}) -> void:
	enemy.emote_emitter.play(name)
	enemy.set_facing(-enemy.facing)
	ignore_timer.start()
	direction_timer.start()

func update(delta : float) -> void:
	if direction_timer.is_stopped():
		enemy.set_facing(-enemy.facing)
		direction_timer.start()
	if ignore_timer.is_stopped():
		enemy.emote_emitter.play("confused")
		finished.emit("idle")
	if enemy.chase_target && !enemy.target_obstructed(enemy.chase_target):
		finished.emit("chase")
