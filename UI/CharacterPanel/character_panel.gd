extends HSplitContainer

@onready var level_label 			: Label = $Stats/MarginContainer/VBoxContainer/LevelLabel
@onready var experience_required 	: Label = $Stats/MarginContainer/VBoxContainer/ExpRequired
@onready var experience_left 		: Label = $Stats/MarginContainer/VBoxContainer/ExpAfterLevelUp

@onready var strength	: StatPanel = $Stats/MarginContainer/VBoxContainer/Strength
@onready var endurance	: StatPanel = $Stats/MarginContainer/VBoxContainer/Endurance
@onready var vitality	: StatPanel = $Stats/MarginContainer/VBoxContainer/Vitality

@onready var details	: RichTextLabel = $Details/MarginContainer/VBoxContainer/DetailsLabel

var level	: int
var xp		: int
var xp_required : int

func open() -> void:
	level = owner.level
	xp = owner.experience_point
	xp_required = owner.get_exp_required_for_level(level)
	show()
	strength.open()
	endurance.open()
	vitality.open()




func close() -> void:
	print("Close character panel")
	strength.close()
	endurance.close()
	vitality.close()
	Talo.events.track("Level up", {
		"New Level": str(owner.level),
		"EXP Left" : str(owner.experience_point),
		"Strength" : str(owner.strength),
		"Endurance": str(owner.endurance),
		"Vitality" : str(owner.vitality),
	})
	hide()


func _process(delta: float) -> void:
	level_label.text = "Level: %s" % str(level)
	experience_required.text = "Required Exp: %s" % str(xp_required)
	experience_left.text = "XP Left: %s" % str(xp)

	var slash_damage_prv	= owner.get_slash_damage()
	var slash_damage_cur 	= owner.get_slash_damage(strength.value_temporary)
	var slash_damage_text	= return_colored_text("Damage", slash_damage_prv, slash_damage_cur)

	var stab_damage_prv		= owner.get_stab_damage()
	var stab_damage_cur 	= owner.get_stab_damage(strength.value_temporary)
	var stab_damage_text	= return_colored_text("Damage", stab_damage_prv, stab_damage_cur)

	var bash_damage_prv 	= owner.get_bash_damage()
	var bash_damage_cur 	= owner.get_bash_damage(strength.value_temporary)
	var bash_damage_text	= return_colored_text("Damage", bash_damage_prv, bash_damage_cur)

	var slash_stamina_cost_prv	= owner.get_slash_stamina_cost()
	var slash_stamina_cost_cur 	= owner.get_slash_stamina_cost(strength.value_temporary, endurance.value_temporary)
	var slash_stamina_cost_text	= return_colored_text("Stamina Cost", slash_stamina_cost_prv, slash_stamina_cost_cur, true)

	var stab_stamina_cost_prv	= owner.get_stab_stamina_cost()
	var stab_stamina_cost_cur 	= owner.get_stab_stamina_cost(strength.value_temporary, endurance.value_temporary)
	var stab_stamina_cost_text	= return_colored_text("Stamina Cost", stab_stamina_cost_prv, stab_stamina_cost_cur, true)

	var bash_stamina_cost_prv 	= owner.get_bash_stamina_cost()
	var bash_stamina_cost_cur 	= owner.get_bash_stamina_cost(strength.value_temporary, endurance.value_temporary)
	var bash_stamina_cost_text	= return_colored_text("Stamina Cost", bash_stamina_cost_prv, bash_stamina_cost_cur, true)

	var slash_sweat_buildup_prv = owner.get_slash_sweat_buildup()
	var slash_sweat_buildup_cur = owner.get_slash_sweat_buildup(strength.value_temporary)
	var slash_sweat_buildup_text= return_colored_text("Sweat Buildup", slash_sweat_buildup_prv, slash_sweat_buildup_cur, true)

	var stab_sweat_buildup_prv	= owner.get_stab_sweat_buildup()
	var stab_sweat_buildup_cur 	= owner.get_stab_sweat_buildup(strength.value_temporary)
	var stab_sweat_buildup_text	= return_colored_text("Sweat Buildup", stab_sweat_buildup_prv, stab_sweat_buildup_cur, true)

	var bash_sweat_buildup_prv 	= owner.get_bash_sweat_buildup()
	var bash_sweat_buildup_cur 	= owner.get_bash_sweat_buildup(strength.value_temporary)
	var bash_sweat_buildup_text	= return_colored_text("Sweat Buildup", bash_sweat_buildup_prv, bash_sweat_buildup_cur, true)

	var slash_fatigue_prv	= owner.get_slash_fatigue()
	var slash_fatigue_cur 	= owner.get_slash_fatigue(strength.value_temporary, endurance.value_temporary)
	var slash_fatigue_text	= return_colored_text("Fatigue", slash_fatigue_prv, slash_fatigue_cur, true)
	
	var stab_fatigue_prv	= owner.get_stab_fatigue()
	var stab_fatigue_cur 	= owner.get_stab_fatigue(strength.value_temporary, endurance.value_temporary)
	var stab_fatigue_text	= return_colored_text("Fatigue", stab_fatigue_prv, stab_fatigue_cur, true)

	var bash_fatigue_prv 	= owner.get_bash_fatigue()
	var bash_fatigue_cur 	= owner.get_bash_fatigue(strength.value_temporary, endurance.value_temporary)
	var bash_fatigue_text	= return_colored_text("Fatigue", bash_fatigue_prv, bash_fatigue_cur, true)

	var str_details = "SLASH"
	str_details += "\n" + slash_damage_text
	str_details += "\n" + slash_stamina_cost_text
	str_details += "\n" + slash_sweat_buildup_text
	str_details += "\n" + slash_fatigue_text + "\n"

	str_details += "\nSTAB"
	str_details += "\n" + stab_damage_text
	str_details += "\n" + stab_stamina_cost_text
	str_details += "\n" + stab_sweat_buildup_text
	str_details += "\n" + stab_fatigue_text + "\n"

	str_details += "\nBASH"
	str_details += "\n" + bash_damage_text
	str_details += "\n" + bash_stamina_cost_text
	str_details += "\n" + bash_sweat_buildup_text
	str_details += "\n" + bash_fatigue_text

	details.text = str_details


func _on_close_pressed() -> void:
	close()


func _on_confirm_pressed() -> void:
	owner.level = level
	owner.experience.lose(owner.experience_point - xp)
	owner.experience_point = xp
	owner.experience_required = xp_required
	owner.strength	= strength.value_temporary
	owner.endurance = endurance.value_temporary
	owner.vitality	= vitality.value_temporary
	close()

func return_colored_text(text:String,prv:float,cur:float,reverse:=false) -> String:
	text += ": "
	if cur > prv:
		if reverse:
			return "[color=red]" + text + str(cur).pad_decimals(1) + "[/color]"
		else:
			return "[color=green]" + text + str(cur).pad_decimals(1) + "[/color]"
	elif cur < prv:
		if reverse:
			return "[color=green]" + text + str(cur).pad_decimals(1) + "[/color]"
		else:
			return "[color=red]" + text + str(cur).pad_decimals(1) + "[/color]"
	else:
		return text + str(cur).pad_decimals(1)
