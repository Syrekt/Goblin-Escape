extends TextureProgressBar

@export var generation_speed := 0.0

var dirt_amount := 0.0


func _process(delta: float) -> void:
	var final_generation_speed = generation_speed + dirt_amount

	var arr : Array = get_children()
	for child in arr:
		if child is Buff:
			final_generation_speed += child.value

	value = move_toward(value, max_value, final_generation_speed * delta)

	var particles : GPUParticles2D = owner.smell_particles
	particles.amount_ratio = (value / max_value)
	


func get_dirty(amount: float) -> void:
	value = move_toward(value, max_value, amount)
	dirt_amount += amount / 100
