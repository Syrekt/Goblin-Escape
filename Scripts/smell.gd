extends StatBar

@export var generation_speed := 0.0

var dirt_amount := 0.0
var semen_amount := 0.0 # Suppress the smell?

func _process(delta: float) -> void:
	var final_generation_speed = clampf(generation_speed + dirt_amount - semen_amount, 0, 5)

	var arr : Array = get_children()
	for child in arr:
		if child is Buff:
			final_generation_speed += child.value

	value = move_toward(value, max_value, final_generation_speed * delta)

	var particles : GPUParticles2D = owner.smell_particles
	particles.amount_ratio = (value / max_value)
	var smell_scale : float = value / max_value
	owner.smell_collider.scale = Vector2(smell_scale, smell_scale)
	


func get_dirty(amount: float) -> void:
	value = move_toward(value, max_value, amount)
	dirt_amount += amount / 100
