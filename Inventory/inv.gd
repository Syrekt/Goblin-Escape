class_name Inventory extends Resource

@export var items : Array[InventoryItem]


func has_item(item: InventoryItem) -> bool:
	for inv_item in items:
		if inv_item.name == item.name:
			return true
	return false
func item_add(item: InventoryItem, amount := 1) -> void:
	for inv_item in items:
		if inv_item && inv_item.name == item.name:
			inv_item.amount += amount
			return

	var item_to_add : InventoryItem = item.duplicate()
	item_to_add.amount = amount
	item_to_add.inventory = self
	items.append(item_to_add)
func item_reduce(item: InventoryItem, amount := 1) -> void:
	for inv_item in items:
		if inv_item && inv_item.name == item.name:
			inv_item.amount -= 1
			if inv_item.amount <= 0:
				items.erase(inv_item)
