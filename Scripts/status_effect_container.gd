class_name StatusEffectContainer extends HBoxContainer

var status_effect_scene := preload("res://Objects/status_effect.tscn")

func add_status_effect(status_effect_name:String,lifetime:=0.0,tick_time:=0.0) -> void:
	print("Adding status effect: " + status_effect_name)

	var status_effect_found := false
	for child in get_children():
		if child.name == status_effect_name:
			status_effect_found = true
			print("Status effect already exists")

	if !status_effect_found:
		var status_effect : StatusEffect = status_effect_scene.instantiate()
		add_child(status_effect)

		match status_effect_name:
			"Bleed":
				status_effect.name = "Bleed"
				status_effect.texture = load("res://UI/Buffs/se_bleed.png")
				add_lifetime(lifetime, status_effect_name, status_effect)

				var effect_timer := Timer.new()
				effect_timer.name = "Effect Timer"
				effect_timer.timeout.connect(_on_bleed_tick)
				status_effect.add_child(effect_timer)
				effect_timer.start(tick_time)
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
	lifetime.name = "Lifetime"
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

func save(save_data:Dictionary) -> void:
	var effects := {}
	for child in get_children():
		var effect_timer : Timer = child.get_node_or_null("Effect Timer")
		var lifetime : Timer = child.get_node_or_null("Lifetime")
		var data = {}
		if effect_timer:
			data.set("tick_time", effect_timer.time_left)
		if lifetime:
			data.set("lifetime", lifetime.time_left)
		effects.set(child.name, data)
	save_data.set("Status Effects", effects)
func load(data:Dictionary) -> void:
	print("data: "+str(data))
	for key in data.keys():
		var effect = data.get(key)
		var lifetime = effect.get("lifetime")
		var tick_time = effect.get("tick_time")
		if !lifetime: lifetime = 0
		if !tick_time: tick_time = 0
		add_status_effect(key, lifetime, tick_time)
