extends TextureProgressBar

@export var recovery_speed := 1.0
@onready var timer = $Timer
var tween : Tween = null

func _process(delta: float) -> void:
	if timer.time_left == 0:
		value = move_toward(value, max_value, recovery_speed*delta)
	Debugger.printui("tween: "+str(tween))
	if tween:
		Debugger.printui("tween.is_running(): "+str(tween.is_running()));

func spend(amount) -> bool:
	if value >= amount:
		value -= amount
		timer.start()
		return true
	else:
		owner.animation_player.play("not_enough_stamina")
		#if tween: tween.stop()
		if tween && tween.is_running(): return false

		tween = create_tween().bind_node(self)
		tween.tween_property(%Sprite2D, "modulate", Color.ORANGE, 0.1)
		tween.tween_property(%Sprite2D, "modulate", Color.WHITE, 0.1)
		tween.tween_property(%Sprite2D, "modulate", Color.ORANGE, 0.1)
		tween.tween_property(%Sprite2D, "modulate", Color.WHITE, 0.1)

		return false
