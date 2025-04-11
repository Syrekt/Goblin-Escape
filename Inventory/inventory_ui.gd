extends PanelContainer

@export var inventory : Inventory

@onready var vbox : VBoxContainer = $MarginContainer/ScrollContainer/ButtonContainer
@onready var slots : Array = $MarginContainer/ScrollContainer/ButtonContainer.get_children()
@onready var button_type = preload("res://Inventory/inv_button.tscn")

func _ready() -> void:
	update()

func update() -> void:
	for i in inventory.items.size():
		var item : InventoryItem = inventory.items[i]
		if item:
			var button : Button = button_type.instantiate()
			vbox.add_child(button)
			button.text = item.name
			button.icon = item.icon
			button.focus_entered.connect(_on_button_focused.bind(item))
			button.owner = owner
			if i == 0: button.grab_focus()

func toggle() -> void:
	visible = !visible
	%DescriptionPanel.visible = visible
	if visible:
		var button : Button = vbox.get_child(0)
		if button:
			button.grab_focus()
func _on_button_focused(item : InventoryItem):
	%DescriptionText.text = item.description
