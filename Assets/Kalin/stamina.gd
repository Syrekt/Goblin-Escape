extends TextureProgressBar

@export var recovery_speed := 1.0

@onready var timer = $Timer

var buff_scene = preload("res://Objects/buff.tscn")

var tween : Tween = null

func _process(delta: float) -> void:
	var final_recovery_speed = recovery_speed

	var arr : Array = get_children()
	for child in arr:
		if child is Buff:
			final_recovery_speed += child.value

	if timer.time_left == 0:
		value = move_toward(value, max_value, recovery_speed*delta)

	Debugger.printui("recovery_speed: "+str(recovery_speed))
	Debugger.printui("final_recovery_speed: "+str(final_recovery_speed))

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

func add_buff(_value : float, _time : float) -> void:
	var buff = buff_scene.instantiate()
	buff.setup(_value, _time)
	add_child(buff)
