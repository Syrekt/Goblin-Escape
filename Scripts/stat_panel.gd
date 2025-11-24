class_name StatPanel extends Control

@onready var stat_name			: String = name
@onready var name_label			: Label = $"NameContainer/Name"
@onready var value_label		: Label = $"ValueContainer/Value"
@onready var button_increase	: Button = $"Increase"
@onready var button_decrease 	: Button = $"Decrease"
@onready var character_panel 	: HSplitContainer = $"../../../.."

var value_permanant : int
var value_temporary : int

func open() -> void:
	print("stat_name: "+str(stat_name))
	value_permanant = owner.get(stat_name.to_lower())
	value_temporary = value_permanant
	print("value_permanant: "+str(value_permanant))

func close() -> void:
	while value_temporary > value_permanant:
		_on_decrease_pressed()


func _process(delta: float) -> void:
	name_label.text = stat_name
	value_label.text = str(value_temporary)

	if character_panel.xp >= character_panel.xp_required:
		button_increase.visible = true
	else:
		button_increase.visible = false


	if value_temporary > value_permanant:
		modulate = Color(0, 1, 0, 1)
		button_decrease.visible = true
	else:
		modulate = Color(1, 1, 1, 1)
		button_decrease.visible = false


func _on_decrease_pressed() -> void:
	if value_temporary > value_permanant:
		value_temporary -= 1
		character_panel.level -= 1
		character_panel.xp += owner.get_exp_required_for_level(character_panel.level)
		character_panel.xp_required = owner.get_exp_required_for_level(character_panel.level)

func _on_increase_pressed() -> void:
	if character_panel.xp >= character_panel.xp_required:
		value_temporary += 1
		character_panel.xp -= character_panel.xp_required
		character_panel.level += 1
		character_panel.xp_required = owner.get_exp_required_for_level(character_panel.level)

	if value_temporary > value_permanant:
		button_decrease.show()
