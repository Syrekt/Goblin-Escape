extends PlayerState

var just_climbed := false

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.call_deferred("update_animation", name)
	lock_stance_button = true;

func update(_delta: float) -> void:
	player.check_movable();
	if lock_stance_button:
		if !player.pressed("stance"): lock_stance_button = false

	if !player.is_on_floor():
		finished.emit("fall")

func handle_input(_event: InputEvent) -> void:
	if player.controls_disabled: return
	if player.movement_disabled: return

	if _event.is_action_pressed("down"):
		finished.emit("crouch")
	elif _event.is_action_pressed("jump"):
		finished.emit("rise")
	elif _event.is_action_pressed("attack") && player.stamina.spend(1.0):
		finished.emit("bash_no_sword")
	elif _event.is_action_pressed("stance") && player.has_sword && !lock_stance_button:
		finished.emit("stance_light")
	elif !is_equal_approx(player.get_movement_dir(), 0.0):
		if _event.is_action_pressed("walk"):
			finished.emit("walk")
		else:
			finished.emit("run")
	elif player.ladder:
		if Input.is_action_pressed("up"):
			finished.emit("ladder_climb")
