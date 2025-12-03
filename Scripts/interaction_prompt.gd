extends AnimatedSprite2D

enum keyboard {
	A = 16,
	B = 17,
	C = 18,
	D = 19,
	E = 20,
	F = 21,
	G = 22,
	H = 23,
	I = 24,
	J = 25,
	K = 26,
	L = 27,
	M = 28,
	N = 29,
	O = 30,
	P = 31,
	Q = 32,
	R = 33,
	S = 34,
	T = 35,
	U = 36,
	V = 37,
	W = 38,
	X = 39,
	Y = 40,
	Z = 41,
}

@onready var label : Label = $Label

var last_input_type := "keyboard"

var supress := false
var _draw := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		last_input_type = "gamepad"
	elif event is InputEventKey || event is InputEventMouse:
		last_input_type = "keyboard"
func _process(delta: float) -> void:
	if _draw:
		visible = !supress
	else:
		visible = false

func _show(action, title := "") -> void:
	if !Ge.show_interaction_prompts:
		print("Interaction prompt is disabled")
		return

	var interaction_prompt = ""
	var events = InputMap.action_get_events(action)
	label.text = title

	if Ge.last_input_type == "keyboard":
		play("keyboard")
		frame = keyboard[Ge.get_action_keycode(action)]
	elif Ge.last_input_type == "gamepad":
		play("xbox")
		frame = int(Ge.get_action_keycode(action))

	_draw = true
func _hide() -> void:
	label.text = ""
	_draw = false
