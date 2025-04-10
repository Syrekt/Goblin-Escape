extends PlayerState

var charge_up := 0.0
var tween : Tween = null

@export var color_charged_up : Color = Color(0.8, 0.8, 0.5, 1)
var c_normal = Color(0, 0, 0, 0)

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
func exit() -> void:
	print("Kill tween")
	if tween: tween.kill()
	tween = null
	charge_up = 0
	%Sprite2D.material.set_shader_parameter("color", Color(0, 0, 0, 0))

func physics_update(delta: float) -> void:
	#Charge up the attack
	if player.pressed("attack"):
		charge_up = move_toward(charge_up, 100, 2)

		Debugger.printui("tween: "+str(tween));
	if charge_up == 100 && !tween:
		print("Start tweening")
		tween = create_tween().bind_node(self)
		tween.tween_property(%Sprite2D.material, "shader_parameter/color", color_charged_up, 0.2)
		tween.tween_property(%Sprite2D.material, "shader_parameter/color", c_normal, 0.2)

	Debugger.printui("charge_up: "+str(charge_up))

	if !player.is_on_floor():
		finished.emit("fall")
	elif player.pressed("stance"):
		finished.emit("idle")
	elif !player.pressed("up"):
		finished.emit("stance_light")
	elif player.pressed("down"):
		finished.emit("stance_defensive")
	elif player.just_released("attack") && player.stamina.spend(player.SLASH_COST):
		finished.emit("slash", {
				"charge_up" : charge_up
			})
	elif !is_equal_approx(player.get_movement_dir(), 0.0):
		finished.emit("stance_walk")
