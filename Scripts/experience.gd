extends TextureProgressBar

func save() -> Dictionary:
	var save_dict = {
		"value" : value,
		"max_value"	: max_value,
	}
	return save_dict

func add(_value : int) -> void:
	print("add expericence: " + str(_value))
	var excess_value = (value + _value) - max_value
	if excess_value > 0:
		print("level up")
		value = excess_value
	else:
		value += _value
