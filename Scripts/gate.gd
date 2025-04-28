extends Node2D

@onready var shape : CollisionShape2D = get_node("Collider/Shape")
@onready var audio_emitter : AudioStreamPlayer2D = $AudioEmitter
@onready var sprite : AnimatedSprite2D = $Sprite
@onready var interaction : Area2D = $Interaction

@export var closed := true
@export var key : InventoryItem


func _process(delta: float) -> void:
	if closed:
		sprite.animation = "closed"
		shape.disabled = false
		interaction.monitorable = true
	else:
		sprite.animation = "open"
		shape.disabled = true
		interaction.monitorable = false
