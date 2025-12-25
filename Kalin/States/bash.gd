extends PlayerAttackState

var enemy_ignore_list := [] # Used for bash

@onready var bash_sfx : FmodEventEmitter2D = $BashSFX
@onready var footstep_emitter : FmodEventEmitter2D = $Footsteps

func enter(previous_state_path: String, data := {}) -> void:
	_enter()
	bash_sfx.set_parameter("AttackResult", "Miss")
	bash_sfx.play()
	enemy_ignore_list = []
	player.set_collision_mask_value(4, true)
	player.fatigue.perform("bash")

func exit() -> void:
	_exit()
	player.set_collision_mask_value(4, false)
	player.power_crush = false

func update(delta: float) -> void:
	_update(delta)
	if player.sprite.frame == 3:
		if player.absorbed_damage:
			print("Absorbed damage and increased velocity")
			player.velocity.x = 300 * player.facing
			player.absorbed_damage = false
		else:
			player.velocity.x = 150 * player.facing


func play_footsteps() -> void:
	footstep_emitter.play()

func _on_bash_hitbox_body_entered(defender: Node2D) -> void:
	var player_bash_damage = player.BASH_DAMAGE + player.BASH_DAMAGE_PER_STRENGTH * player.strength

	if enemy_ignore_list.has(defender): return
	enemy_ignore_list.append(defender)

	if defender is Enemy:
		var defender_state = defender.state_node.state.name

		defender.combat_properties.pushback_apply(player.global_position, pushback_force)
		if !defender.in_combat: # Stun
			defender.combat_properties.stun(2.0)
			bash_sfx.set_parameter("AttackResult", "Hit")
		elif !defender_state == "stance_defensive": # Deal damage
			defender.take_damage(player_bash_damage, player)
			Ge.slow_mo(0, 0.05)
			bash_sfx.set_parameter("AttackResult", "Hit")
		else: # Opponent defending
			bash_sfx.set_parameter("AttackResult", "Blocked")
		bash_sfx.play()
	else:
		defender.take_damage(0, player)

		player.hurt_sfx.play()
		player.think(["Ouch!", "Bad idea", "I should use a weapon"].pick_random())

		finished.emit("hurt" if player.has_sword else "hurt_no_sword")
