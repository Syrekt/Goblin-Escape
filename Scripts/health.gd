extends Node

@export var bar: TextureProgressBar

@export var max := 100
var prv = max
var cur = max

signal health_depleted


func change_by(value: int) -> void:
	cur = clamp(cur - value, 0, max)
	if get_node_or_null("TextureProgressBar"):
		TextureProgressBar.value = cur
	if cur <= 0: emit_signal("health_depleted")
