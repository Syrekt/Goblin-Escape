extends CanvasLayer

var finished := false
var faded_in := false

var from_options_menu := false ## Means player opened the tutorial from options menu

var silent := false ## Disable opening sfx when it's opened from tutorials tab

@export var code : String

@onready var label			:= $ColorControl/Control/Label
@onready var container		:= $ColorControl/TabContainer
@onready var color_control	:= $ColorControl
@onready var button_control := $ColorControl/Control

@onready var left : Button = find_child("Left")
@onready var right : Button = find_child("Right")


func _ready() -> void:
	if !get_tree().paused: ## Means that we are in menu so don't play sfx
		Game.get_singleton().player.tutorial_sfx.play()

	left.pressed.connect(_on_left_pressed)
	right.pressed.connect(_on_right_pressed)

	container.current_tab = 0
	$TutorialContinuePrompt.hide()
	button_control.hide()

	color_control.modulate = Color(1.0, 1.0, 1.0, 0.0)

	var tween = create_tween().bind_node(self)
	if from_options_menu:
		tween.tween_property(color_control, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.0)
		$Timer.wait_time = 0.1
	else:
		tween.tween_property(color_control, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2)

	container.tab_changed.connect(_on_tab_container_tab_changed)
	$Timer.timeout.connect(_on_timer_timeout)

	get_tree().paused = true

	if container.current_tab == container.get_tab_count() - 1:
		$Timer.start()
	else:
		tween.tween_callback(show_controls)

	var button = $TutorialContinuePrompt/NinePatchRect/MarginContainer/VBoxContainer/Button
	button.pressed.connect(_on_button_pressed)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _process(delta: float) -> void:
	var tab_count = container.get_tab_count()
	label.text = str(container.current_tab + 1) + "/" + str(container.get_tab_count())
	if faded_in:
		if Input.is_action_just_pressed("left"):
			container.select_previous_available()
		if Input.is_action_just_pressed("right"):
			container.select_next_available()

	if finished:
		if Input.is_action_just_pressed("stance"): _on_button_pressed()
		if !from_options_menu && Input.is_action_just_pressed("ui_cancel"): _on_button_pressed()

	get_tree().root.set_input_as_handled()
	

func show_controls() -> void:
	button_control.visible = true
	faded_in = true

#region Signals
func _on_tab_container_tab_changed(tab: int) -> void:
	print("tab: "+str(tab))
	if tab == container.get_tab_count() - 1:
		$Timer.start()
func _on_timer_timeout() -> void:
	finished = true
	$TutorialContinuePrompt.show()
func _on_right_pressed() -> void:
	print("right pressed")
	container.select_next_available()
func _on_left_pressed() -> void:
	print("left pressed")
	container.select_previous_available()
func _on_button_pressed() -> void:
	if !from_options_menu: get_tree().paused = false
	queue_free()
#endregion

func _exit_tree() -> void:
	Game.get_singleton().persistent_values.set("Tutorial-" + code, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Ge.notify("[color=red]" + code + "[/color] tutorial added to [color=red]Options[/color] menu.")
