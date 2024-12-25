extends Node

@export var max_health: int = 100
var prv_health = max_health
var cur_health = max_health

signal health_changed(new_health)


func take_damage(damage: int) -> void:
	cur_health = clamp(cur_health - damage, 0, max_health)
	emit_signal("health_changed", cur_health)
