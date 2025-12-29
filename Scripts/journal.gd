extends CanvasLayer

@onready var tab_container: TabContainer = $TextureRect/TabContainer

var current_logbook : TabContainer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		tab_container.select_next_available()
	elif Input.is_action_just_pressed("up"):
		tab_container.select_previous_available()

	current_logbook = tab_container.get_current_tab_control()

	if Input.is_action_just_pressed("left"):
		current_logbook.select_previous_available()
	elif Input.is_action_just_pressed("right"):
		current_logbook.select_next_available()

	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
