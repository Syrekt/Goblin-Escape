extends PlayerAttackState

var enemy_ignore_list := [] # Used for bash

func enter(previous_state_path: String, data := {}) -> void:
	_enter()
	player.play_sfx(sfx_whiff)
	enemy_ignore_list = []
	player.set_collision_mask_value(4, true)

func exit() -> void:
	player.set_collision_mask_value(4, false)

func update(delta: float) -> void:
	_update(delta)
	if player.sprite.frame == 3:
		if player.absorbed_damage:
			print("Absorbed damage and increased velocity")
			player.velocity.x = 300 * player.facing
			player.absorbed_damage = false
		else:
			player.velocity.x = 200 * player.facing


func play_footsteps() -> void:
	Ge.play_audio_from_string_array(%AnimationAudioStreamer, 1, "res://SFX/Kalin/Footsteps Soft/")

func _on_bash_hitbox_body_entered(defender: Node2D) -> void:
	if enemy_ignore_list.has(defender): return
	enemy_ignore_list.append(defender)

	if defender is Enemy:
		var defender_state = defender.state_node.state.name
		player.play_sfx(sfx_hit)

		defender.combat_properties.pushback_apply(player.global_position, pushback_force)
		if !defender.in_combat:
			defender.combat_properties.stun(2.0)
		elif !defender_state == "stance_defensive":
			defender.take_damage(0, player)
			Ge.slow_mo(0, 0.05)
		else:
			Ge.play_audio_from_string_array(player.audio_emitter, 0, "res://SFX/Sword hit shield")
