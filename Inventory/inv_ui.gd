extends PanelContainer

@onready var vbox : VBoxContainer = $MarginContainer/ScrollContainer/ButtonContainer
@onready var slots : Array = $MarginContainer/ScrollContainer/ButtonContainer.get_children()
@onready var button_scene = preload("res://Inventory/inv_button.tscn")

@export var inventory : Inventory

var item_list : Array


#region Methods
func _ready() -> void:
	item_list = inventory.items
func _process(delta: float) -> void:
	if !get_viewport().gui_get_focus_owner():
		%DescriptionText.text = ""
		if vbox.get_child_count() > 0:
			vbox.get_child(0).grab_focus()
func toggle() -> void:
	visible = !visible
	%DescriptionPanel.visible = visible
	if visible:
		for item in item_list:
			if item:
				create_button(item)
		if vbox.get_child_count() > 0:
			vbox.get_child(0).grab_focus()
	else:
		for child in vbox.get_children():
			child.queue_free()
func create_button(item : InventoryItem) -> void:
	var button : Button = button_scene.instantiate()
	vbox.add_child(button)
	button.owner = owner
	button.focus_entered.connect(_on_focus_entered.bind(item))

	button.item = item
#endregion
#region Signals
func _on_focus_entered(item : InventoryItem) -> void:
	if item:
		%DescriptionText.text = item.description
#endregion
