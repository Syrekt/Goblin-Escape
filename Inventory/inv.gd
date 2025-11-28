class_name Inventory extends Resource

@export var items : Array[InventoryItem]


func has_item(item: InventoryItem) -> bool:
	for inv_item in items:
		if inv_item.name == item.name:
			return true
	return false
func item_add(item, amount := 1) -> void:
	for inv_item in items:
		if inv_item && inv_item.name == item.item_name:
			inv_item.amount += amount
			return

	var item_to_add : InventoryItem = InventoryItem.new()
	item_to_add.name = item.item_name
	item_to_add.description = item.item_description
	item_to_add.icon = load(item.icon_path)
	item_to_add.inventory = self

	items.append(item_to_add)
func item_reduce(item:InventoryItem, amount := 1) -> void:
	for inv_item in items:
		if inv_item && inv_item.name == item.name:
			inv_item.amount -= 1
			if inv_item.amount <= 0:
				items.erase(inv_item)
