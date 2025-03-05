extends CharacterBody2D

var grabbed = false

func grab() -> void:
	grabbed = true

func release() -> void:
	velocity = Vector2.ZERO
	grabbed = false


func _physics_process(delta: float) -> void:
	if(!grabbed && !is_on_floor()):
		velocity += get_gravity() * delta
	move_and_slide()
