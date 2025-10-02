extends PanelContainer

@onready var level_label : Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var experience_required : Label = $MarginContainer/VBoxContainer/ExpRequired


func _process(delta: float) -> void:
	level_label.text = "Level: " + str(owner.level)
	experience_required.text = "Required Exp: " + str(owner.experience_required)


func _on_close_pressed() -> void:
	hide()
