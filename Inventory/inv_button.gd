extends Button

var item : InventoryItem

func _process(delta: float) -> void:
	if !item:
		print("destroy button")
		queue_free()
		item = null
		return

	text = item.name
	icon = item.icon
	$Label.text = str(item.amount)

func use() -> bool:
	if !item.consumable: return false
	#returns destroyed

	item.inventory.item_reduce(item)

	return item.amount <= 0

func _on_pressed() -> void:
	match text:
		"Health Potion":
			print("Drink health potion")
			owner.health.value += 6
		"Water":
			print("Drink water")
			owner.stamina.add_buff(0.5, 10.0)
		"Perfume":
			print("Use perfume")
			owner.smell.value = 0;
			owner.smell.add_buff(-10, 10)
	if use():
		queue_free()
