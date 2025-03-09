extends TextureProgressBar

@export var recovery_speed := 1.0
@onready var timer = $Timer

func _process(delta: float) -> void:
	if timer.time_left == 0:
		value = move_toward(value, max_value, recovery_speed*delta)

func spend(amount) -> bool:
	if value >= amount:
		value -= amount
		timer.start()
		return true
	else:
		owner.animation_player.play("not_enough_stamina")
		return false
