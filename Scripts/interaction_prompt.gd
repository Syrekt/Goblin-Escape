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

@onready var label : Label = get_node("../CanvasLayer/InteractionLabel")

var last_input_type := "keyboard"

var supress := false
var _draw := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		last_input_type = "gamepad"
	elif event is InputEventKey || event is InputEventMouse:
		last_input_type = "keyboard"
func _process(delta: float) -> void:
	Debugger.printui("label.text: "+str(label.text));
	if _draw:
		visible = !supress
	else:
		visible = false

func _show(title := "") -> void:
	var interaction_prompt = ""
	var events = InputMap.action_get_events("interact")
	label.text = title

	if events.size() > 0:
		for event in events:
			if event is InputEventKey:
				interaction_prompt = OS.get_keycode_string(event.physical_keycode)
				if last_input_type == "keyboard":
					play("keyboard")
					frame = keyboard[interaction_prompt]
			elif event is InputEventJoypadButton:
				print("Gamepad Button " + str(event.button_index))
				if last_input_type == "gamepad":
					play("xbox")
					frame = event.button_index

	_draw = true
func _hide() -> void:
	label.text = ""
	_draw = false
