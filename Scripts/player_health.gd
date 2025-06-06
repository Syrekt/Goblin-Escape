extends StatBar

@export var regeneration_speed := 0.01

var tween : Tween
var tint_under_tween : Tween
var tint_over_tween : Tween

const TINT_KALIN	= Color.RED
const TINT_SPRITE	= Color.RED

func _process(delta: float) -> void:
	var final_regeneration_speed = regeneration_speed

	value += final_regeneration_speed * delta

	if final_regeneration_speed > regeneration_speed:
		if !tint_under_tween:
			tint_under_tween = create_tween().bind_node(self)
			tint_under_tween.set_loops(-1)
			tint_under_tween.tween_property(self, "tint_under", Color.GREEN, 1.0)
			tint_under_tween.tween_property(self, "tint_under", Color.WHITE, 1.0)
	elif tint_under_tween:
		tint_under_tween.kill()
		tint_under_tween = null

func save() -> Dictionary:
	var save_dict = {
		"value"	: value,
		"max_value"	: max_value
	}
	return save_dict
