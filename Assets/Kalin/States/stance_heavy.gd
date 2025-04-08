extends PlayerState

var charge_up := 0.0
var tween : Tween = null

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
func exit() -> void:
	print("Kill tween")
	if tween: tween.kill()
	tween = null
	charge_up = 0

func physics_update(delta: float) -> void:
	#Charge up the attack
	if Input.is_action_pressed("attack"):
		charge_up = move_toward(charge_up, 100, 2)

		Debugger.printui("tween: "+str(tween));
	if charge_up == 100 && !tween:
		print("Start tweening")
		tween = create_tween().bind_node(self)
		var c = Color(0.3, 0.3, 0.8, 1)
		tween.tween_property(%Sprite2D, "modulate", c, 0.1)
		tween.tween_property(%Sprite2D, "modulate", Color.WHITE, 0.1)

	Debugger.printui("charge_up: "+str(charge_up))

	if !player.is_on_floor():
		finished.emit("fall")
	elif Input.is_action_pressed("stance"):
		finished.emit("idle")
	elif !Input.is_action_pressed("up"):
		finished.emit("stance_light")
	elif Input.is_action_pressed("down"):
		finished.emit("stance_defensive")
	elif Input.is_action_just_released("attack") && player.stamina.spend(player.SLASH_COST):
		finished.emit("slash")
	elif !is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("stance_walk")
