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

	for i in range(tab_container.get_tab_count()):
		tab_container.set_tab_title(i, " ")




func _process(delta: float) -> void:
	var tab = tab_container.current_tab
	var tab_count = tab_container.get_tab_count()
	if Input.is_action_just_pressed("down"):
		var next = tab_container.current_tab + 1
		if next < tab_container.get_tab_count():
			start_page_animation("change_header_left")
			tab_container.current_tab = next
	elif Input.is_action_just_pressed("up"):
		var next = tab_container.current_tab - 1
		if next > -1:
			start_page_animation("change_header_right")
			tab_container.current_tab = next

	current_logbook = tab_container.get_current_tab_control()

	if current_logbook:
		if Input.is_action_just_pressed("left"):
			if current_logbook.select_previous_available():
				start_page_animation("left")
		elif Input.is_action_just_pressed("right"):
			if current_logbook.select_next_available():
				start_page_animation("right")

	if Input.is_action_just_pressed("ui_cancel"):
		_on_close_button_pressed()


func start_page_animation(anim:String):
	$PaperFlipSFX.play()
	tab_container.hide()
	close_button.hide()
	page_animation.play(anim)


func _on_page_animation_animation_finished() -> void:
	tab_container.show()
	close_button.show()


func _on_close_button_pressed() -> void:
	queue_free()
