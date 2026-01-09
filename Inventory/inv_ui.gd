extends PanelContainer

@onready var vbox : VBoxContainer = find_child("ButtonContainer") #$MarginContainer/ScrollContainer/ButtonContainer
@onready var slots : Array = vbox.get_children()
@onready var button_scene = preload("res://Inventory/inv_button.tscn")
@onready var ui_focus : ColorRect = $"../../Overlays/UIFocus"
@onready var description_panel : PanelContainer = owner.find_child("DescriptionPanel")
@onready var description_text : RichTextLabel = owner.find_child("DescriptionText")
@onready var scroll_bar = $MarginContainer/ScrollContainer

@export var inventory : Inventory

var item_list : Array
var player : Player


#region Methods
func _ready() -> void:
	item_list = inventory.items
	hide()
	description_panel.hide()
	scroll_bar.get_v_scroll_bar().set_scale(Vector2(0.5, 1))
func _process(delta: float) -> void:
	if !get_viewport().gui_get_focus_owner():
		description_text.text = ""
		if vbox.get_child_count() > 0:
			vbox.get_child(0).grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if !Game.get_singleton().player.controls_disabled:
			toggle()
func toggle() -> void:
	visible = !visible
	description_panel.visible = visible

	if visible:
		open()
	else:
		close()
func open() -> void:
	visible = true
	description_panel.visible = true

	ui_focus.fade_in()
	for item in item_list:
		if item:
			create_button(item)
	if vbox.get_child_count() > 0:
		vbox.get_child(0).grab_focus()
func close() -> void:
	visible = false
	description_panel.visible = false

	ui_focus.fade_out()
	for child in vbox.get_children():
		child.queue_free()
func create_button(item : InventoryItem) -> void:
	var button : Button = button_scene.instantiate()
	vbox.add_child(button)
	button.owner = owner
	button.focus_entered.connect(_on_focus_entered.bind(button, item))
	button.mouse_entered.connect(_on_focus_entered.bind(button, item))

	button.item = item
#endregion
#region Signals
func _on_focus_entered(button,item : InventoryItem) -> void:
	button.grab_focus()
	if item:
		description_text.text = item.description
#endregion

func save(save_data) -> void:
	var game = Game.get_singleton()
	var player_inventory : Array[Dictionary]
	for item in inventory.items:
		print("Save item: " + str(item))
		player_inventory.append({"name":item.name, "amount":item.amount})
	save_data.set("inventory", player_inventory)
func load(data: Dictionary) -> void:
	inventory = Inventory.new()
	item_list = inventory.items
	var loaded_inventory = data.inventory
	for item in loaded_inventory:
		print("Add item: " + item.name)
		inventory.item_add(ImportData.item_data.get(item.name), item.amount)
