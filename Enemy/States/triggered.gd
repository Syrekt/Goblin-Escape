extends EnemyState

@onready var ignore_timer : Timer = $IgnoreTimer
@onready var direction_timer : Timer = $DirectionTimer

func enter(previous_state_path : String, data = {}) -> void:
	enemy.emote_emitter.play(name)
	enemy.set_facing(-enemy.facing)
	ignore_timer.start()
	direction_timer.start()
	enemy.aware = true

func update(delta : float) -> void:
	if direction_timer.is_stopped():
		enemy.set_facing(-enemy.facing)
		direction_timer.start()

	if ignore_timer.is_stopped():
		enemy.emote_emitter.play("confused")
		enemy.patrolling = true
		finished.emit("idle")
		return

	if enemy.chase_target && await enemy.detect_player(enemy.chase_target):
		finished.emit("chase")
		return
