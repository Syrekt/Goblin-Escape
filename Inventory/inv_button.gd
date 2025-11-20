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
	#returns true if destroyed

	if item.consumable:
		item.inventory.item_reduce(item)

	return item.amount <= 0

func _on_pressed() -> void:
	match text:
		"Health Potion":
			print("Drink health potion")
			owner.health.value += 50
		"Water":
			print("Drink water")
			owner.stamina.add_buff(0.5, 10.0)
		"Stenchbane":
			print("Use Stenchbane")
			owner.smell.value = 0;
			owner.smell.add_buff(-10, 10)
		"Feather Step":
			print("Use feather step")
		"Bandage":
			print("Use bandage")
		"Minor Rejuvenation Draught":
			print("Use Minor Rejuvenation Draught")
		"Pher Potion":
			print("Use Pher Potion")
		"Urgent Letter":
			var thought = [
				"I shouldn't read this.",
				"I might be too late but I can't open this."
			].pick_random()
			owner.think(thought)
		"_":
			print("This item has no use")
	if use():
		queue_free()
