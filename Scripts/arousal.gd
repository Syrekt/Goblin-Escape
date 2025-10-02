extends TextureProgressBar

var pregnancy_chance := 0.0

func _process(delta: float) -> void:
	pregnancy_chance = value / 100.0
	#Debugger.printui("pregnancy_chance: "+str(pregnancy_chance))

func save() -> void:
	var save_data = {
		"value"	: value,
	}
	Ge.save_node(self, save_data)
