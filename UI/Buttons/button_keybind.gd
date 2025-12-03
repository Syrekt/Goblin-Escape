class_name KeyRebindButton
extends Control

@onready var button := $Button
@onready var label  := $Label

@export var action_name := ""

var button_pressed := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_action_name()
	set_process_unhandled_key_input(false)
	set_text_for_key()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func set_action_name() -> void:
	match action_name:
		"up":
			label.text = "Up"
		"down":
			label.text = "Down"
		"left":
			label.text = "Left"
		"right":
			label.text = "Right"
		"attack":
			label.text = "Attack"
		"stance":
			label.text = "Stance"
		"jump":
			label.text = "Jump"
		"sprint":
			label.text = "Sprint"
		"walk":
			label.text = "Walk"

func set_text_for_key() -> void:
	#print("Set text for key: " + name)
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	#print("action_event: "+str(action_event.physical_keycode))
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)

	button.text = action_keycode;
	#print(action_keycode)


func _on_button_toggled(_button_pressed: bool) -> void:
	if _button_pressed:
		button.text = "Press any key..."
		set_process_unhandled_key_input(_button_pressed)

		for i in get_tree().get_nodes_in_group("key_bind_buttons"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_nodes_in_group("key_bind_buttons"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)

		set_text_for_key()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		#print("event.keycode: "+str(event.keycode));
		#print("KEY_ESCAPE: "+str(KEY_ESCAPE))
		if event.keycode == KEY_ESCAPE:
			set_action_name()
			button.button_pressed = false
		else:
			rebind_action_key(event)
			button.button_pressed = false

func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)

	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
