# Needs Player collision mask enabled for collision detection to be collected
# Experince is multiplied by 100 at the add() function

class_name Collectable extends RigidBody2D

var being_pulled := false
var puller : CharacterBody2D
var speed := 0.0
@onready var idle_timer : Timer = $Timer
@onready var experience_sprite := preload("res://Objects/experience_orb.png")
@onready var sprite : Sprite2D = $Sprite2D
@export var pull_speed := 10000.0

enum Types {
	EXPERIENCE = 1,
}
var type : int
var amount := 1

func _ready() -> void:
	match type:
		Types.EXPERIENCE:
			sprite.texture = experience_sprite
		"_":
			print("Missing collectable sprite")

func _physics_process(delta: float) -> void:
	if being_pulled && idle_timer.is_stopped():
		var dir := (Ge.player.global_position - global_position).normalized()

		# Accelerate
		speed = lerpf(speed, pull_speed, 0.1)
		# Move
		linear_velocity = speed * dir * delta

		# If distance is smaller than 16 get collected
		var dist = abs(global_position - puller.global_position)
		if global_position.distance_to(puller.global_position) < 16:
			get_collected()

func start_pull(_puller: CharacterBody2D) -> void:
	puller = _puller
	being_pulled = true

func get_collected() -> void:
	match type:
		Types.EXPERIENCE:
			puller.experience.add(amount * 1)
		"_":
			print("No collectable type")
	queue_free()
