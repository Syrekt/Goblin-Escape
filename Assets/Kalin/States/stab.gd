extends PlayerState

@onready var hitbox = get_child(0)
@onready var sfx_stab_hit = load("res://Assets/SFX/Kalin/stab1.wav")
@onready var sfx_stab_whiff = load("res://Assets/SFX/Kalin/Sword Woosh 12.wav")

@export var pushback_force := 100

signal attack_frame

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)

func update(delta):
	if !player.is_on_floor():
		finished.emit("fall")

func _on_attack_frame() -> void:
	print("stab hit")
	#player.combat_perform_attack(hitbox, player.stab_damage, sfx_stab_whiff, sfx_stab_hit, 75)
	if hitbox.has_overlapping_bodies():
		var defender : Enemy = hitbox.get_overlapping_bodies()[0]
		var defender_state = defender.state_node.state.name
		if defender_state == "stance_defensive":
			player.combat_properties.stun(2.0)
			Ge.play_audio_from_string_array(player.audio_emitter, 0, "res://Assets/SFX/Sword hit shield")
		else:
			defender.combat_properties.pushback_apply(player.global_position, pushback_force)
			defender.take_damage(player.stab_damage, player)
			player.play_sfx(sfx_stab_hit)
	else:
		player.play_sfx(player.sfx_stab_whiff)
