extends PlayerState

var tween : Tween = null

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	tween = create_tween().bind_node(self)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color(0.0, 0.0, 0.0, 0.0), 0.1)

func exit() -> void:
	tween.kill()
	tween = null
