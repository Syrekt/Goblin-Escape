extends CanvasLayer

var finished := false

func _ready() -> void:
	$TabContainer.current_tab = 0
	$Control/Close.hide()
	$ContinuePrompt.hide()

func _process(delta: float) -> void:
	$Control/Label.text = str($TabContainer.current_tab + 1) + "/" + str($TabContainer.get_tab_count())
	if Input.is_action_just_pressed("left"):
		$TabContainer.select_previous_available()
	if Input.is_action_just_pressed("right"):
		$TabContainer.select_next_available()

	if finished && (Input.is_action_just_pressed("stance") || Input.is_action_just_pressed("ui_cancel")):
		queue_free()


func _on_tab_container_tab_changed(tab: int) -> void:
	if tab == 2:
		$Timer.start()


func _on_timer_timeout() -> void:
	finished = true
	$ContinuePrompt.show()
	$Control/Close.show()


func _on_right_pressed() -> void:
	print("right pressed")
	$TabContainer.select_next_available()


func _on_left_pressed() -> void:
	print("left pressed")
	$TabContainer.select_previous_available()


func _on_button_pressed() -> void:
	queue_free()
