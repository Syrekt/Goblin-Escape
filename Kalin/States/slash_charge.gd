extends PlayerState

var charge_up := 10.0

@onready var charge_fx : AnimatedSprite2D = $"../../SlashChargeupFX"

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	charge_fx.show()
	charge_fx.play("charging")

func exit() -> void:
	charge_fx.stop()
	charge_fx.hide()
	charge_up = 0

func physics_update(delta: float) -> void:
	# Charge up the attack
	if player.pressed("attack"):
		charge_up = move_toward(charge_up, 100, 2)

	if charge_up == 100:
		if !charge_fx.visible:
			charge_fx.show()
			charge_fx.play("charged")
		player.call_deferred("update_animation", "slash_charged")

	if !player.is_on_floor():
		finished.emit("fall")
	elif player.pressed("stance"):
		finished.emit("idle")
	elif !player.pressed("up"):
		finished.emit("stance_light")
	elif player.pressed("down"):
		finished.emit("stance_defensive")
	elif player.just_released("attack") && player.stamina.spend(player.SLASH_STAMINA_COST, 2.0):
		finished.emit("slash", {
				"charge_up" : charge_up
			})
	elif !is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("stance_walk")
