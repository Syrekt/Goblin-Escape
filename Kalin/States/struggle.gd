extends PlayerState

@onready var timer : Timer = $Timer
@onready var progression_bar : TextureProgressBar = $"../../StruggleProgressBar"
@onready var struggle_prompt : AnimatedSprite2D = $"../../StruggleProgressBar/AnimatedSprite2D"

var tween : Tween


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	progression_bar.show()
	struggle_prompt._show("attack")
	progression_bar.value = progression_bar.max_value / 2

	tween = create_tween().bind_node(self).set_loops(-1)
	var tween_speed = 0.1
	tween.tween_property(struggle_prompt, "position:y", -8, tween_speed)
	tween.tween_property(struggle_prompt, "position:y", -11, tween_speed)

func exit() -> void:
	progression_bar.hide()
	tween.kill()


func physics_update(delta: float) -> void:
	progression_bar.value = move_toward(progression_bar.value, 0, 40 * delta)
	player.set_facing(player.grabbed_by.global_position.x - player.global_position.x)
	if Input.is_action_just_pressed("attack"):
		progression_bar.value += 20.0
	if progression_bar.value >= progression_bar.max_value:
		player.break_grab()
	elif progression_bar.value <= 0.0:
		player.sex_begin([player.grabbed_by], "sex_goblin1")
