extends PlayerState

@onready var hitbox = get_child(0)
@onready var sfx_stab_hit = load("res://Assets/SFX/Kalin/stab1.wav")
@onready var sfx_stab_whiff = load("res://Assets/SFX/Kalin/Sword Woosh 12.wav")

signal attack_frame

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)

func update(delta):
	if !player.is_on_floor():
		finished.emit("fall")

func _on_attack_frame() -> void:
	print("stab hit")
	player.combat_perform_attack(hitbox, sfx_stab_whiff, sfx_stab_hit, 75)
