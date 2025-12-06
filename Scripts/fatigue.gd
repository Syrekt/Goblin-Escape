extends TextureProgressBar

func _process(delta: float) -> void:
	if !owner.status_effect_container.has_status_effect("Resilience"):
		value += 0.00001

func add(amount: float) -> void:
	if amount < 0:
		print("Fatigue buildup can't be negative number")
		return
	value += amount
func perform(action: String) -> void:
	var fatigue_buildup_mod := 0.0
	if owner.status_effect_container.has_status_effect("Resilience"):
		fatigue_buildup_mod = 0.9
	print("fatigue_buildup_mod: "+str(fatigue_buildup_mod))
	var p = owner
	var fatigue_addup = float(p.strength) / float(p.strength + p.endurance)
	match action:
		"slash":
			#value += p.MAX_SLASH_FATIGUE * ((p.strength * p.SLASH_FATIGUE_STRENGTH_MOD) / (p.endurance * p.SLASH_FATIGUE_ENDURANCE_MOD))
			print("Before buildup mod: " + str(fatigue_addup * p.MAX_SLASH_FATIGUE))
			print("After buildup mod: " + str(fatigue_addup * p.MAX_SLASH_FATIGUE * fatigue_buildup_mod))
			value += fatigue_addup * p.MAX_SLASH_FATIGUE * fatigue_buildup_mod
		"stab":
			#value += p.MAX_STAB_FATIGUE * ((p.strength * p.STAB_FATIGUE_STRENGTH_MOD) / (p.endurance * p.STAB_FATIGUE_ENDURANCE_MOD))
			value += fatigue_addup * p.MAX_STAB_FATIGUE * fatigue_buildup_mod
		"bash":
			#value += p.MAX_BASH_FATIGUE * ((p.strength * p.BASH_FATIGUE_STRENGTH_MOD) / (p.endurance * p.BASH_FATIGUE_ENDURANCE_MOD))
			value += fatigue_addup * p.MAX_BASH_FATIGUE * fatigue_buildup_mod
	print("action: %s - fatigue: %d" %[action, value])
