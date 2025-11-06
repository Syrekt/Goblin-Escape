extends CanvasLayer

var finished := false
var faded_in := false

@onready var label			:= $ColorControl/Control/Label
@onready var container		:= $ColorControl/TabContainer
@onready var close_button	:= $ColorControl/Control/Close
@onready var color_control	:= $ColorControl
@onready var button_control := $ColorControl/Control


func _ready() -> void:
	container.current_tab = 0
	close_button.hide()
	$ContinuePrompt.hide()
	button_control.hide()

	color_control.modulate = Color(1.0, 1.0, 1.0, 0.0)

	var tween = create_tween().bind_node(self)
	tween.tween_property(color_control, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2)

	container.tab_changed.connect(_on_tab_container_tab_changed)
	$Timer.timeout.connect(_on_timer_timeout)

	get_tree().paused = true

	if container.current_tab == container.get_tab_count() - 1:
		$Timer.start()
	else:
		tween.tween_callback(show_controls)



func _process(delta: float) -> void:
	var tab_count = container.get_tab_count()
	label.text = str(container.current_tab + 1) + "/" + str(container.get_tab_count())
	if faded_in:
		if Input.is_action_just_pressed("left"):
			container.select_previous_available()
		if Input.is_action_just_pressed("right"):
			container.select_next_available()

	if finished && (Input.is_action_just_pressed("stance") || Input.is_action_just_pressed("ui_cancel")):
		get_tree().paused = false
		queue_free()

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
	$ContinuePrompt.show()
	close_button.show()
func _on_right_pressed() -> void:
	print("right pressed")
	container.select_next_available()
func _on_left_pressed() -> void:
	print("left pressed")
	container.select_previous_available()
func _on_button_pressed() -> void:
	queue_free()
#endregion
