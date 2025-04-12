extends PanelContainer

@onready var vbox : VBoxContainer = $MarginContainer/ScrollContainer/ButtonContainer
@onready var slots : Array = $MarginContainer/ScrollContainer/ButtonContainer.get_children()
@onready var button_scene = preload("res://Inventory/inv_button.tscn")


#region Methods
func _process(delta: float) -> void:
	if !get_viewport().gui_get_focus_owner():
		if vbox.get_child_count() > 0:
			vbox.get_child(0).grab_focus()
func toggle() -> void:
	visible = !visible
	%DescriptionPanel.visible = visible
	if visible:
		if vbox.get_child_count() > 0:
			var button : Button = vbox.get_child(0)
			if button:
				button.grab_focus()
func create_button(item : InventoryItem) -> void:
	var button : Button = button_scene.instantiate()
	vbox.add_child(button)
	button.owner = owner
	button.focus_entered.connect(_on_focus_entered.bind(item))

	button.item = item

func pickup_item(item_to_add : InventoryItem) -> void:
	#Item exists in Inventory
	for button in vbox.get_children():
		if button.item.name == item_to_add.name:
			button.item.amount += 1
			return
	#If item doesn't exists
	create_button(item_to_add)
#endregion
#region Signals
func _on_focus_entered(item : InventoryItem) -> void:
	%DescriptionText.text = item.description
#endregion
