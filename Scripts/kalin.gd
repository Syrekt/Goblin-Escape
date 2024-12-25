class_name Player extends CharacterBody2D

@onready var animation_player := $AnimatedSprite2D

@export var speed := 200.0
@export var gravity := 1000.0
@export var jump_impulse := 200.0

@onready var state_node := get_node("StateMachine")

var facing: int = 1

func set_facing(dir := 0):
	facing = dir
	animation_player.flip_h = facing

func _process(delta: float) -> void:
	if state_node.state != $StateMachine/landing:
		var dir = Input.get_axis("left", "right")
		if(dir != 0):
			set_facing(dir == -1)
		else:
			set_facing(facing)

func _on_animated_sprite_2d_animation_finished() -> void:
	print("animation end")
	if animation_player.animation == "landing":
		$StateMachine.state.finished.emit("idle")
