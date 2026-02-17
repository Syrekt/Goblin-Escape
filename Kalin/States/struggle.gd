extends PlayerState

@onready var timer : Timer = $Timer
@onready var progression_bar : TextureProgressBar = $"../../StruggleProgressBar"
@onready var struggle_prompt : AnimatedSprite2D = $"../../StruggleProgressBar/AnimatedSprite2D"
@onready var arousal_bar : TextureProgressBar = $"../../UI/HUD/Scaled/Arousal"

var tween : Tween


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	progression_bar.show()
	struggle_prompt._show("attack")
	progression_bar.value = progression_bar.max_value / 2
	Talo.events.track("Struggle started")

	tween = create_tween().bind_node(self).set_loops(-1)
	var tween_speed = 0.1
	tween.tween_property(struggle_prompt, "position:y", -8, tween_speed)
	tween.tween_property(struggle_prompt, "position:y", -11, tween_speed)


func exit() -> void:
	progression_bar.hide()
	tween.kill()


func physics_update(delta:float) -> void:
	if !player.grabbed_by:
		finished.emit("idle")
		return

	player.stamina.spend(0.01)

	progression_bar.value = move_toward(progression_bar.value, 0, 40 * delta)
	# Make sure player is looking towards enemy
	player.set_facing(player.grabbed_by.global_position.x - player.global_position.x)

	# High arousal makes it harder to break
	var arousal_modifier = (arousal_bar.value / arousal_bar.max_value) * 5.0

	if Input.is_action_just_pressed("attack"): # Struggle
		progression_bar.value += 20.0 - arousal_modifier
	if progression_bar.value >= progression_bar.max_value: # Break free
		player.break_grab()
	elif progression_bar.value <= 0.0 || !player.stamina.has_enough(0.1): # Lose struggle
		if Options.adult_content_enabled:
			player.grabbed_by.state_node.state.finished.emit(player.grabbed_by.transition_state)
			finished.emit(player.grabbed_by.transition_state)
			Talo.events.track("Struggle failed")
		else:
			player.grabbed_by.state_node.state.finished.emit("slash")
			player.break_grab()
			Talo.events.track("Struggle succeded")
