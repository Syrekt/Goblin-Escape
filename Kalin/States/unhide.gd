extends PlayerState

var tween : Tween = null

func enter(previous_state_path : String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.hiding = false
	player.set_collision_layer_value(2, true)
	player.set_collision_mask_value(4, true)
	tween = create_tween().bind_node(self)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", player.current_tint, 0.1)

func exit() -> void:
	tween.kill()
	tween = null
