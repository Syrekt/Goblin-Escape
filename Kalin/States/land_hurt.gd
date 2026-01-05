extends PlayerState

var tween : Tween = null

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.take_damage(data.fall_damage, null, false)
	player.ignore_corners = false
	player.velocity = Vector2.ZERO
	player.hurt_sfx.set_parameter("DamageType", "Fall")
	player.hurt_sfx.play()
	
	tween = create_tween().bind_node(self)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color(1.0, 0, 0.22, 1.0), 0.1)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", player.current_tint, 0.1)

func exit() -> void:
	if tween:
		tween.kill()
		tween = null
