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
	var used = true
	match text:
		"Cheese", "Bread", "Dried Fish":
			owner.health.value += 10
		"Health Potion":
			print("Drink health potion")
			owner.health.value += 50
		"Water":
			print("Drink water")
			#owner.stamina.add_buff(0.5, 10.0)
		"Stenchbane":
			print("Use Stenchbane")
			owner.smell.value = 0;
			#owner.smell.add_buff(-10, 10)
		"Feather Step":
			print("Use feather step")
		"Bandage":
			if owner.status_effect_container.has_status_effect("Bleed"):
				owner.status_effect_container.remove_status_effect("Bleed")
			else:
				used = false
				owner.think(["I don't need this", "I'm not bleeding"].pick_random())
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
	if used && use():
		queue_free()
