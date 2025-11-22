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
	var fatigue_addup = float(p.strength) / float(p.strength + p.endurance)
	match action:
		"slash":
			#value += p.MAX_SLASH_FATIGUE * ((p.strength * p.SLASH_FATIGUE_STRENGTH_MOD) / (p.endurance * p.SLASH_FATIGUE_ENDURANCE_MOD))
			value += fatigue_addup * p.MAX_SLASH_FATIGUE
		"stab":
			#value += p.MAX_STAB_FATIGUE * ((p.strength * p.STAB_FATIGUE_STRENGTH_MOD) / (p.endurance * p.STAB_FATIGUE_ENDURANCE_MOD))
			value += fatigue_addup * p.MAX_STAB_FATIGUE
		"bash":
			#value += p.MAX_BASH_FATIGUE * ((p.strength * p.BASH_FATIGUE_STRENGTH_MOD) / (p.endurance * p.BASH_FATIGUE_ENDURANCE_MOD))
			value += fatigue_addup * p.MAX_BASH_FATIGUE
	print("action: %s - fatigue: %d" %[action, value])
