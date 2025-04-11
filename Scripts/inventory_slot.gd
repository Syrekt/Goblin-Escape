extends HBoxContainer

@onready var button : Button = $Button

func _ready() -> void:
	pass

func update(item : InventoryItem) -> void:
	button.text = item.name
	button.icon = item.icon

func use() -> void:
	print("Used item")


func _on_button_pressed() -> void:
	use()
