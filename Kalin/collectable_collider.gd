extends Area2D

func _physics_process(delta: float) -> void:
	if has_overlapping_areas():
		for body in get_overlapping_areas():
			body.owner.start_pull(get_parent())
