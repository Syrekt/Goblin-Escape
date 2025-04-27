extends Camera2D

var region : Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if region:
		limit_left		= region.limit_left
		limit_right 	= region.limit_right
		limit_top		= region.limit_top
		limit_bottom	= region.limit_bottom
	else:
		limit_left		= -10000000
		limit_right 	= 10000000
		limit_top		= -10000000
		limit_bottom	= 10000000
