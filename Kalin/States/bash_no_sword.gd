extends PlayerAttackState

var enemy_ignore_list := [] # Used for bash

@onready var bash_sfx : FmodEventEmitter2D = $"../bash/BashSFX"
@onready var footstep_emitter : FmodEventEmitter2D = $"../bash/Footsteps"

func enter(previous_state_path: String, data := {}) -> void:
	_enter()
	if previous_state_path == "run": # Override the animation set in _enter()
		player.call_deferred("update_animation", "bash_running")

	bash_sfx.set_parameter("AttackResult", "Miss")
	bash_sfx.play()
	enemy_ignore_list = []
	player.set_collision_mask_value(4, true)

func exit() -> void:
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
			player.velocity.x = 200 * player.facing


func play_footsteps() -> void:
	footstep_emitter.play()

func _on_hitbox_body_entered(defender: Node2D) -> void:
	if enemy_ignore_list.has(defender): return
	enemy_ignore_list.append(defender)

	if defender is Enemy:
		var defender_state = defender.state_node.state.name

		defender.combat_properties.pushback_apply(player.global_position, pushback_force)
		if !defender.in_combat:
			defender.combat_properties.stun(2.0)
			bash_sfx.set_parameter("AttackResult", "Hit")
		elif !defender_state == "stance_defensive":
			defender.take_damage(1, player)
			Ge.slow_mo(0, 0.05)
			bash_sfx.set_parameter("AttackResult", "Hit")
		else:
			bash_sfx.set_parameter("AttackResult", "Blocked")
		bash_sfx.play()
	else:
		defender.take_damage(0, player)

		bash_sfx.set_parameter("AttackResult", "HitOnWood")
		bash_sfx.play()

		player.think(["Ouch!", "Bad idea", "I should use a weapon"].pick_random())

		finished.emit("hurt_no_sword")
