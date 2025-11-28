extends Node

var item_data : Dictionary

func _ready() -> void:
	var item_data_file = FileAccess.open("res://Inventory/Goblin Escape - ItemTable.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(item_data_file.get_as_text())
	if error == OK:
		item_data = json.data
		print("Loaded item data")
	else:
		print("Failed to load item data")
