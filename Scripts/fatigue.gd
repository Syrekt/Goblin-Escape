extends TextureProgressBar

func _process(delta: float) -> void:
	value += 0.00001

func add(amount: float) -> void:
	if amount < 0:
		print("Fatigue buildup can't be negative number")
		return
	value += amount
func perform(action: String) -> void:
	var p = owner
	match action:
		"slash":
			value += p.SLASH_FATIGUE * ((p.strength * p.SLASH_FATIGUE_STRENGTH_MOD) / (p.endurance * p.SLASH_FATIGUE_ENDURANCE_MOD))
		"stab":
			value += p.STAB_FATIGUE * ((p.strength * p.STAB_FATIGUE_STRENGTH_MOD) / (p.endurance * p.STAB_FATIGUE_ENDURANCE_MOD))
		"bash":
			value += p.BASH_FATIGUE * ((p.strength * p.BASH_FATIGUE_STRENGTH_MOD) / (p.endurance * p.BASH_FATIGUE_ENDURANCE_MOD))
	print("action: %s - fatigue: %d" %[action, value])
