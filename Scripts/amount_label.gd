extends Label

var amount : int

func _process(delta: float) -> void:
	visible = amount != 0
	if amount > 0:
		text = "+" + str(amount)
	else:
		text = str(amount)
