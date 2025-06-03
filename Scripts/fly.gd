extends CharacterBody2D

var speed := 0.0
var direction := 0

@onready var sprite := $AnimatedSprite2D
@onready var light := $PointLight2D
var checkpoint : Interaction
var lifetime := 0


func _ready() -> void:
	lifetime = randi_range(8, 16);
	speed = randf_range(0.1, 0.2)*60.0
	direction = randi_range(45, 135)
	var rad = deg_to_rad(direction)
	velocity = Vector2(cos(rad)*speed, -sin(rad)*speed)
	sprite.play(["1", "2", "3"].pick_random())
	if velocity.x < 0:
		print("sprite: "+str(sprite))
		sprite.flip_h = true

	var tween_strength = create_tween().bind_node(self)
	tween_strength.tween_property(light, "energy", 1, 2.0)
	tween_strength.tween_property(light, "energy", 0, lifetime)
	tween_strength.tween_callback(_on_lifetime_timeout)

	var tween_alpha = create_tween().bind_node(self)
	tween_alpha.tween_property(sprite, "self_modulate:a", 1.0, 2.0)
	tween_alpha.tween_property(sprite, "self_modulate:a", 0.0, lifetime)


func _process(delta: float) -> void:
	move_and_slide()


func _on_lifetime_timeout() -> void:
	#checkpoint.spawn_fly()
	queue_free()
