extends TextureProgressBar

@export var recovery_speed := 1.0
@onready var timer = $Timer
var tween : Tween = null

func _process(delta: float) -> void:
	if timer.time_left == 0:
		value = move_toward(value, max_value, recovery_speed*delta)

func spend(amount: float) -> bool:
	if value >= amount:
		value -= amount
		timer.start()
		return true
	else:
		blink()
		return false

func has_enough(amount: float) -> bool:
	if value < amount: blink()
	return value >= amount

func blink() -> void:
	if tween && tween.is_running(): return 

	tween = create_tween().bind_node(self)
	tween.tween_property(%Sprite2D, "modulate", Color.ORANGE, 0.1)
	tween.tween_property(%Sprite2D, "modulate", Color.WHITE, 0.1)
	tween.tween_property(%Sprite2D, "modulate", Color.ORANGE, 0.1)
	tween.tween_property(%Sprite2D, "modulate", Color.WHITE, 0.1)

	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
