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
	item.amount -= 1
	if item.amount <= 0:
		queue_free()
		return true
	return false

func _on_pressed() -> void:
	match text:
		"Health Potion":
			print("Drink health potion")
			%Health.value += 6
		"Water":
			print("Drink water")
			%Stamina.add_buff(0.5, 10.0)
	use();
