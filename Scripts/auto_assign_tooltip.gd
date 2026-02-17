extends Control

var _tooltip_text : String

func _ready() -> void:
	_tooltip_text = tooltip_text
	tooltip_text = ""

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	owner.tooltip.show_tip(_tooltip_text)
	print("_tooltip_text: "+str(_tooltip_text))

func _on_mouse_exited() -> void:
	owner.tooltip.hide()
