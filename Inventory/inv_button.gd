extends Button

var stamina : TextureProgressBar


func _on_pressed() -> void:
	print("owner: "+str(owner))
	print("Button pressed")
	print("name: "+str(text))
	match text:
		"Health Potion":
			print("Drink health potion")
			%Health.change_by(6)
		"Water":
			print("Drink water")
			%Stamina.add_buff(0.5, 10.0)
