extends Area2D

@onready var cooldown : Timer = $Cooldown

func interact() -> void:
	cooldown.start()

func _process(delta: float) -> void:
	set_collision_mask_value(7, cooldown.time_left <= 0)
