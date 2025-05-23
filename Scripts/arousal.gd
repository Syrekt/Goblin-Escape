extends TextureProgressBar

var pregnancy_chance := 0.0

func _process(delta: float) -> void:
	pregnancy_chance = value / 100.0
	Debugger.printui("pregnancy_chance: "+str(pregnancy_chance))

func save() -> Dictionary:
	var save_dict = {
		"value" : value,
		"max_value"	: max_value,
	}
	return save_dict
