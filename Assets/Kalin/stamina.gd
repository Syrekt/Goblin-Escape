extends TextureProgressBar

@export var recovery_speed := 1.0

@onready var timer = $Timer

var buff_scene = preload("res://Objects/buff.tscn")

var tween : Tween = null
var tint_under_tween : Tween = null

func _process(delta: float) -> void:
	var final_recovery_speed = recovery_speed

	var arr : Array = get_children()
	for child in arr:
		if child is Buff:
			final_recovery_speed += child.value

	if timer.time_left == 0:
		value = move_toward(value, max_value, recovery_speed*delta)

	if final_recovery_speed > recovery_speed:
		if !tint_under_tween:
			tint_under_tween = create_tween().bind_node(self)
			tint_under_tween.set_loops(-1)
			tint_under_tween.tween_property(self, "tint_under", Color.GREEN, 1.0)
			tint_under_tween.tween_property(self, "tint_under", Color.WHITE, 1.0)
	elif tint_under_tween:
		tint_under_tween.kill()
		tint_under_tween = null


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
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color.ORANGE, 0.1)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color(0, 0, 0, 0), 0.1)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color.ORANGE, 0.1)
	tween.tween_property(%Sprite2D.material, "shader_parameter/tint_color", Color(0, 0, 0, 0), 0.1)

	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func add_buff(_value : float, _time : float) -> void:
	var buff = buff_scene.instantiate()
	add_child(buff)
	buff.setup(_value, _time)
