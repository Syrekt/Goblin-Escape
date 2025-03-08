extends Node

@onready var bar := $Bar

@export var max := 100
var prv : float
var cur : float

signal health_depleted

func _ready() -> void:
	prv = max
	cur = max
	bar.value = (cur/max)*100.0


func change_by(value: int) -> void:
	cur = clamp(cur + value, 0, max)
	print("cur: "+str(cur))
	print("max: "+str(max))
	bar.value = (cur/max)*100.0
	print("(cur/max)*100: "+str((cur/max)*100));
	print("bar.value: "+str(bar.value));
	if cur <= 0:
		print("Emit death signal")
		emit_signal("health_depleted")
