extends CharacterBody2D

@export var speed := 0.0
@export_range(0, 360) var direction := 0

#@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
var checkpoint : Interaction

var lifetime : Timer


func _ready() -> void:
	#print("checkpoint: "+str(checkpoint))
	velocity = Vector2(sin(direction)*speed, cos(direction)*speed)
	#if velocity.x < 0:
	#	print("sprite: "+str(sprite))
	#	sprite.flip_h = true

	lifetime = Timer.new()
	lifetime.timeout.connect(_on_lifetime_timeout)
	lifetime.one_shot = true
	add_child(lifetime)
	lifetime.start(randf_range(3, 5))


func _process(delta: float) -> void:
	move_and_slide()


func _on_lifetime_timeout() -> void:
	checkpoint.spawn_fly()
	queue_free()
