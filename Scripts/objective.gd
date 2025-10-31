class_name Objective extends Sprite2D

var map_icon := "objective"
var draw_on_map := true
@export var active := false

func _ready() -> void:
	hide()
func _process(delta: float) -> void:
	draw_on_map = active
