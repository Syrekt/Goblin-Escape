extends TextureProgressBar


var prv : float
var cur : float

signal health_depleted

func _ready() -> void:
	prv = max_value
	cur = max_value
	value = (cur/max_value)*100.0


func change_by(_value: int) -> void:
	cur = clamp(cur + _value, 0, max_value)
	value = cur
	if cur <= 0:
		emit_signal("health_depleted")
