class_name StatusEffectContainer extends HBoxContainer

var status_effect_scene := preload("res://Objects/status_effect.tscn")

func add_status_effect(status_effect_name:String) -> void:
	print("Adding status effect: " + status_effect_name)
	var status_effect : StatusEffect = status_effect_scene.instantiate()
	add_child(status_effect)

	match status_effect_name:
		"Bleed":
			status_effect.name = "Bleed"
			status_effect.texture = load("res://UI/Buffs/se_bleed.png")
			add_lifetime(5, status_effect_name, status_effect)

			var effect_timer := Timer.new()
			effect_timer.timeout.connect(_on_bleed_tick)
			status_effect.add_child(effect_timer)
			effect_timer.start(0.1)
		"Death's Door":
			status_effect.name = "Death's Door"
			status_effect.texture = load("res://UI/Buffs/se_death.png")


func has_status_effect(_name:String) -> bool:
	for child in get_children():
		if child.name == _name:
			return true

	return false

func remove_status_effect(_name:String) -> bool: ## Return true if status effect found and deleted
	for child in get_children():
		if child.name == _name:
			child.queue_free()
			return true

	return false

func add_lifetime(time:float,_name:String,status_effect:StatusEffect) -> void:
	var lifetime : Timer = Timer.new()
	status_effect.add_child(lifetime)
	lifetime.one_shot = true
	lifetime.start(time)
	lifetime.timeout.connect(_on_lifetime_timeout.bind(_name))


func _on_lifetime_timeout(_name) -> void:
	print("Status effect %s timeout" %_name)
	for child in get_children():
		if child.name == _name:
			child.queue_free()

func _on_bleed_tick() -> void:
	owner.health.value -= 0.5
