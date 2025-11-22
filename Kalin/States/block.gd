extends PlayerState

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	Ge.play_audio_from_string_array(player.global_position, 1.0, "res://SFX/Sword block")
func exit() -> void:
	player.parried = false
func update(delta: float) -> void:
	if player.parried && player.just_pressed("attack"):
		Ge.kill_slow_mo()
		if player.stamina.spend(player.stab_cost, 1.0):
			finished.emit("slash")
		elif player.stamina.spend(player.stab_cost, 1.0):
			finished.emit("stab")
