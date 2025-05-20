extends PanelContainer

@onready var vbox : VBoxContainer = $MarginContainer/ScrollContainer/ButtonContainer
@onready var slots : Array = $MarginContainer/ScrollContainer/ButtonContainer.get_children()
@onready var button_scene = preload("res://Inventory/inv_button.tscn")
@onready var ui_focus : ColorRect = get_node("../UIFocus")
@onready var description_panel : PanelContainer = get_node("../DescriptionPanel")
@onready var description_text : RichTextLabel = get_node("../DescriptionPanel/MarginContainer/DescriptionText")

@export var inventory : Inventory

var item_list : Array
var player : Player


#region Methods
func _ready() -> void:
	item_list = inventory.items
	hide()
	description_panel.hide()
func _process(delta: float) -> void:
	if !get_viewport().gui_get_focus_owner():
		description_text.text = ""
		if vbox.get_child_count() > 0:
			vbox.get_child(0).grab_focus()
func toggle() -> void:
	visible = !visible
	description_panel.visible = visible

	if visible:
		ui_focus.fade_in()
		for item in item_list:
			if item:
				create_button(item)
		if vbox.get_child_count() > 0:
			vbox.get_child(0).grab_focus()
	else:
		ui_focus.fade_out()
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
		description_text.text = item.description
#endregion
