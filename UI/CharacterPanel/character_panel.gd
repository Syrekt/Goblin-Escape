extends HSplitContainer

@onready var level_label 			: Label = $Stats/MarginContainer/VBoxContainer/LevelLabel
@onready var experience_required 	: Label = $Stats/MarginContainer/VBoxContainer/ExpRequired
@onready var experience_left 		: Label = $Stats/MarginContainer/VBoxContainer/ExpAfterLevelUp

@onready var strength	: StatPanel = $Stats/MarginContainer/VBoxContainer/Strength
@onready var endurance	: StatPanel = $Stats/MarginContainer/VBoxContainer/Endurance
@onready var vitality	: StatPanel = $Stats/MarginContainer/VBoxContainer/Vitality

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
	strength.close()
	endurance.close()
	vitality.close()
	hide()


func _process(delta: float) -> void:
	level_label.text = "Level: %s" % str(level)
	experience_required.text = "Required Exp: %s" % str(xp_required)
	experience_left.text = "XP Left: %s" % str(xp)


func _on_close_pressed() -> void:
	close()


func _on_confirm_pressed() -> void:
	print("Confirm changes")
	owner.level = level
	owner.experience.lose(owner.experience_point - xp)
	owner.experience_point = xp
	owner.experience_required = xp_required
	owner.strength	= strength.value_temporary
	owner.endurance = endurance.value_temporary
	owner.vitality	= vitality.value_temporary
	close()
