extends TextureProgressBar

func save() -> Dictionary:
	var save_dict = {
		"value" : value,
		"max_value"	: max_value,
	}
	return save_dict
