extends PlayerState

@export var pushback_force := 100

@onready var hitbox : Area2D = get_child(0)
@onready var sfx_slash_hit = load("res://Assets/SFX/Kalin/HIT 01.wav")
@onready var sfx_slash_whiff = load("res://Assets/SFX/Kalin/Heavy sword woosh 11.wav")

var charge_up := 0.0

signal attack_frame

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = 0;
	charge_up = data.charge_up

func update(delta):
	if !player.is_on_floor():
		finished.emit("fall")

func _on_attack_frame() -> void:
	print("slash hit")
	var damage = player.slash_damage * 2 if charge_up == 100 else player.slash_damage
	print("damage: "+str(damage))
	#player.combat_perform_attack(hitbox, damage, sfx_slash_whiff, sfx_slash_hit, pushback_force)
	if hitbox.has_overlapping_bodies():
		var defender : Enemy = hitbox.get_overlapping_bodies()[0]
		var defender_state = defender.state_node.state.name
		if defender_state == "stance_defensive":
			defender.combat_properties.stun(2.0)
			Ge.play_audio(player.audio_emitter, 1, "res://Assets/SFX/Kalin/block_break2.wav")
		else:
			defender.take_damage(damage, player)
			player.play_sfx(sfx_slash_hit)
		defender.combat_properties.pushback_apply(player.global_position, pushback_force)
	else:
		player.play_sfx(sfx_slash_whiff)
