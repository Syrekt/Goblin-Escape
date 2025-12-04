extends Button

var item

@onready var suicide_confirm := preload("res://UI/suicide_confirm.tscn")

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
			if owner.health.value == owner.health.max_value:
				owner.think("I'm not hungry.")
			else:
				owner.health.value += 10
		"Health Potion":
			if owner.health.value == owner.health.max_value:
				owner.think("I don't need this.")
			else:
				owner.health.value += 50
		"Water":
			print("Drink water")
			if owner.status_effect_container.has_status_effect("Hydrated"):
				owner.think("I'm not thirsty.. yet.")
			else:
				owner.status_effect_container.add_status_effect("Hydrated", 60.0, 0.1)
		"Stenchbane":
			print("Use stenchbane")
			owner.status_effect_container.add_status_effect("Stenchbane")
		"Feather Step":
			print("Use feather step")
			owner.status_effect_container.add_status_effect("Feather Step", 10*60)
		"Bandage":
			if owner.status_effect_container.has_status_effect("Bleed"):
				owner.status_effect_container.remove_status_effect("Bleed")
			else:
				used = false
				owner.think(["I don't need this", "I'm not bleeding"].pick_random())
		"Minor Rejuvenation Draught":
			print("Use Minor Rejuvenation Draught")
			if owner.status_effect_container.has_status_effect("Minor Rejuvenation"):
				owner.think("I shouldn't drink this too much.")
			else:
				owner.status_effect_container.add_status_effect("Minor Rejuvenation", 60.0, 0.1)
		"Pher Potion":
			print("Use Pher Potion")
			if owner.smell.value < owner.smell.max_value:
				owner.smell.value += 100
				owner.think("Not sure if this is a good idea...")
			else:
				owner.think("I don't need this.")
		"Urgent Letter":
			var thought = [
				"I shouldn't read this.",
				"I might be too late but I can't open this."
			].pick_random()
			owner.think(thought)
		"Revenant's Draught":
			print("Use revenant's draught")
			get_tree().current_scene.add_child(suicide_confirm.instantiate())
			owner.inventory_panel.toggle()
			used = false
		"Infertility Potion":
			print("Used infertility potion")
		"_":
			print("This item has no use")
	if used && use():
		queue_free()
