extends PlayerState

@onready var block_emitter : FmodEventEmitter2D = $BlockEmitter

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	block_emitter.play()
func exit() -> void:
	player.parried = false
func update(delta: float) -> void:
	if player.parried && player.just_pressed("attack"):
		Ge.kill_slow_mo()
		if player.stamina.spend(player.stab_cost, 1.0):
			finished.emit("slash")
		elif player.stamina.spend(player.stab_cost, 1.0):
			finished.emit("stab")
