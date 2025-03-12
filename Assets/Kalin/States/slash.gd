extends PlayerState

@export var knockback_force := 100

@onready var hitbox = get_child(0)
@onready var sfx_slash_hit = load("res://Assets/SFX/Kalin/HIT 01.wav")
@onready var sfx_slash_whiff = load("res://Assets/SFX/Kalin/Heavy sword woosh 11.wav")

signal attack_frame

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = 0;

func update(delta):
	if !player.is_on_floor():
		finished.emit("fall")

func _on_attack_frame() -> void:
	print("slash hit")
	player.combat_perform_attack(hitbox, sfx_slash_whiff, sfx_slash_hit, knockback_force)
