extends CanvasLayer

@onready var tab_container: TabContainer = $TextureRect/TabContainer
@onready var page_animation: AnimatedSprite2D = $TextureRect/PageAnimation
@onready var close_button: Button = $TextureRect/CloseButton

var current_logbook : TabContainer

func _ready() -> void:
	var game = Game.get_singleton()
	for diary_owner in tab_container.get_children():
		var pages = game.logs.get(diary_owner.name)
		if(!pages):
			diary_owner.queue_free()
		else:
			for i in range(diary_owner.get_children().size()):
				# i+1 because we start counting pages from 1 but array from 0
				if !pages.get(i + 1):
					diary_owner.get_child(i).queue_free()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		tab_container.select_next_available()
	elif Input.is_action_just_pressed("up"):
		tab_container.select_previous_available()

	current_logbook = tab_container.get_current_tab_control()

	if current_logbook:
		if Input.is_action_just_pressed("left"):
			if current_logbook.select_previous_available():
				tab_container.hide()
				close_button.hide()
				page_animation.play("left")
		elif Input.is_action_just_pressed("right"):
			if current_logbook.select_next_available():
				tab_container.hide()
				close_button.hide()
				page_animation.play("right")

	if Input.is_action_just_pressed("ui_cancel"):
		_on_close_button_pressed()


func _on_page_animation_animation_finished() -> void:
	tab_container.show()
	close_button.show()


func _on_close_button_pressed() -> void:
	queue_free()
