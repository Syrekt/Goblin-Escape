class_name PlayerAttackState extends PlayerState

@onready var hitbox : Area2D = get_child(0)
@export var sfx_hit		: Resource
@export var sfx_whiff	: Resource
@export var pushback_force := 100

var can_buffer_next_attack := false

signal attack_frame

func _enter() -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = 0;

func _update(delta: float) -> void:
	if !player.is_on_floor():
		finished.emit("fall")
	if can_buffer_next_attack:
		if player.just_pressed("attack"):
			if player.pressed("up"):
				player.buffered_state = "slash"
			elif player.pressed("down"):
				player.buffered_state = "bash"
