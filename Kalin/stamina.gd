extends StatBar

@export var regeneration_speed := 1.0

@onready var timer = $Timer
const TINT_KALIN	= Color.ORANGE
const TITN_SPRITE	= Color.RED

var tint_under_tween : Tween

func _process(delta: float) -> void:
	var final_regeneration_speed = regeneration_speed

	var arr : Array = get_children()
	for child in arr:
		if child is Buff:
			final_regeneration_speed += child.value

	if timer.time_left == 0:
		value = move_toward(value, max_value, regeneration_speed*delta)

	if final_regeneration_speed > regeneration_speed:
		if !tint_under_tween:
			tint_under_tween = create_tween().bind_node(self)
			tint_under_tween.set_loops(-1)
			tint_under_tween.tween_property(self, "tint_under", Color.GREEN, 1.0)
			tint_under_tween.tween_property(self, "tint_under", Color.WHITE, 1.0)
	elif tint_under_tween:
		tint_under_tween.kill()
		tint_under_tween = null


func spend(amount: float, smell := 0.0) -> bool:
	if value >= amount:
		value -= amount
		timer.start()
		owner.smell.get_dirty(smell)
		return true
	else:
		blink(TINT_KALIN, TITN_SPRITE)
		return false

func has_enough(amount: float) -> bool:
	if value < amount: blink(TINT_KALIN, TITN_SPRITE)
	return value >= amount


func add_buff(_value : float, _time : float) -> void:
	var buff = buff_scene.instantiate()
	add_child(buff)
	buff.setup(_value, _time)
