extends StatBar

@export var regeneration_speed := 1.0

@onready var timer = $Timer
const TINT_KALIN	= Color.ORANGE
const TINT_SPRITE	= Color.RED

var tint_under_tween : Tween
var tint_over_tween  : Tween

@export var fade_out_col : Color = Color(0.125, 0.125, 0.125, 1.0)

func _process(delta: float) -> void:
	var final_regeneration_speed = regeneration_speed
	if owner.status_effect_container.has_status_effect("Hydrated"):
		final_regeneration_speed += 0.1

	var arr : Array = get_children()
	for child in arr:
		if child is StatusEffect:
			final_regeneration_speed += child.value

	if timer.time_left == 0 && !owner.dead && !owner.unconscious:
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


func spend(amount: float, smell := 0.0, allow_vfx := true) -> bool:
	if value >= amount:
		value -= amount
		timer.start()
		owner.smell.get_dirty(smell)
		return true
	else:
		if allow_vfx:
			blink(TINT_KALIN, TINT_SPRITE)
		return false

func has_enough(amount: float) -> bool:
	if value < amount: blink(TINT_KALIN, TINT_SPRITE)
	return value >= amount


func fade_out() -> void:
	if tint_over_tween		: tint_over_tween.kill()

	tint_over_tween = create_tween().bind_node(self)
	tint_over_tween.tween_property(self, "tint_over", fade_out_col, 1.0)


func fade_in() -> void:
	if tint_over_tween		: tint_over_tween.kill()

	tint_over_tween = create_tween().bind_node(self)
	tint_over_tween.tween_property(self, "tint_over", Color.WHITE, 1.0)
