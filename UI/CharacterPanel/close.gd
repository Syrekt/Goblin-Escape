extends Button

@onready var character_panel = $"../../.."


func _on_pressed() -> void:
	print("close pressed")
	character_panel.hide()
