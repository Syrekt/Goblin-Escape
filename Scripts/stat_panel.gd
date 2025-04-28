extends Control

@onready var stat_name : String = name
@onready var name_label : Label = get_node("HBoxContainer/NameContainer/Name")
@onready var value_label : Label = get_node("HBoxContainer/ValueContainer/Value")
@onready var button_increase : Button = get_node("HBoxContainer/Increase")
@onready var button_decrease : Button = get_node("HBoxContainer/Decrease")

func _process(delta: float) -> void:
	name_label.text = stat_name
	value_label.text = str(owner.get(stat_name.to_lower()))
	if owner.available_stat_points > 0:
		button_increase.visible = true
		#button_decrease.visible = true
	else:
		button_increase.visible = false
		#button_decrease.visible = false


func _on_decrease_pressed() -> void:
	var value = owner.get(stat_name.to_lower())
	if value > 0:
		owner.set(stat_name.to_lower(), value - 1)
		owner.available_stat_points += 1

func _on_increase_pressed() -> void:
	if owner.available_stat_points > 0:
		var value = owner.get(stat_name.to_lower())
		owner.set(stat_name.to_lower(), value + 1)
		owner.available_stat_points -= 1
