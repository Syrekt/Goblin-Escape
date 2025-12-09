extends CharacterBody2D

@onready var sprite := $Sprite2D

var move_speed := 6000 * 60
var directional_speed := 0.0
var laughing := false



func move(dir:int) -> void:
	directional_speed = move_speed * dir


func _physics_process(delta: float) -> void:

	velocity.x = directional_speed * delta

	sprite.flip_h = sign(velocity.x) == -1

	directional_speed = 0
