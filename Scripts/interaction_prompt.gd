extends AnimatedSprite2D

enum keyboard {
	Up		= 0,
	Down	= 1,
	Left 	= 2,
	Right	= 3,
	F1	= 4,
	F2 	= 5,
	F3 	= 6,
	F4 	= 7,
	F5 	= 8,
	F6 	= 9,
	F7 	= 10,
	F8 	= 11,
	F9 	= 12,
	F10 = 13,
	F11 = 14,
	F12 = 15,
	A	= 16,
	B 	= 17,
	C 	= 18,
	D 	= 19,
	E 	= 20,
	F 	= 21,
	G 	= 22,
	H 	= 23,
	I 	= 24,
	J 	= 25,
	K 	= 26,
	L 	= 27,
	M 	= 28,
	N 	= 29,
	O 	= 30,
	P 	= 31,
	Q 	= 32,
	R 	= 33,
	S 	= 34,
	T 	= 35,
	U 	= 36,
	V 	= 37,
	W 	= 38,
	X 	= 39,
	Y 	= 40,
	Z 	= 41,
	Period			= 42,
	Comma			= 43,
	Backspace		= 44,
	Slash			= 45,
	Backslash		= 46,
	Semicolon 		= 47,
	Apostrophe		= 48,
	BracketLeft		= 49,
	BracketRight	= 50,
	Equal			= 51,
	Minus			= 52,
	Asciitilde		= 53,
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
		#Debugger.printui("Interaction prompt is disabled")
		return

	var interaction_prompt = ""
	var events = InputMap.action_get_events(action)
	label.text = title

	if Ge.last_input_type == "keyboard":
		play("keyboard")
		var button = Ge.get_action_keycode(action)
		if keyboard.has(button):
			frame = keyboard[button]
			_draw = true
		else:
			print("Can't find input in keyboard keys")
	elif Ge.last_input_type == "gamepad":
		play("xbox")
		var f = int(Ge.get_action_keycode(action))
		if f < sprite_frames.get_frame_count("xbox"):
			frame = f
			_draw = true
		else:
			print("Can't find input in xbox animation")

func _hide() -> void:
	label.text = ""
	_draw = false
