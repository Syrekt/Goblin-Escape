extends PlayerState

var tween : Tween
var tween_step : Tween
var target_position : Vector2

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)

	tween_step = create_tween().bind_node(self)
	target_position = Vector2(player.hiding_spot.global_position.x + player.facing*6, player.global_position.y)
	var distance = target_position - player.global_position
	tween_step.tween_property(player, "global_position", player.global_position + distance/2, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func leave() -> void:
	tween.kill()
	tween_step.kill()

func take_step() -> void:
	tween_step = create_tween().bind_node(self)
	tween_step.tween_property(player, "global_position", target_position, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func fade_out() -> void:
	tween = create_tween().bind_node(self)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color(0.1, 0.1, 0.1, 1.0), 0.1)
