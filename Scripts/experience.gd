# I should save the existing exp drop in this node
extends Label

var visible_amount := 0
var amount := 0
var experience_drop = preload("res://Objects/dropped_experience.tscn")
var previous_drop : Area2D ## Keeps track of previously dropped exp
@onready var amount_container = $"../../../ExpAmountContainer"
@onready var amount_label = $"../../../ExpAmountContainer/AmountLabel"

@onready var timer : Timer = $Timer

var tween_label : Tween
var tween_amount : Tween

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func save() -> Dictionary:
	var save_dict = {
		"amount" : amount,
	}
	return save_dict

func add(_amount: int) -> void:
	print("_amount: "+str(_amount))
	timer.start()
	amount += _amount
	amount_label.amount += _amount

func lose(_amount: int) -> void:
	timer.start()
	amount -= _amount
	amount_label.amount -= _amount

func _on_timer_timeout() -> void:
	if tween_label:		tween_label.kill()
	if tween_amount:	tween_amount.kill()

	tween_label = create_tween().bind_node(self)
	tween_label.tween_property(amount_label, "amount", 0, 2)

	tween_amount = create_tween().bind_node(self)
	tween_amount.tween_property(self, "visible_amount", amount, 2)

	

func _process(delta: float) -> void:
	var spd = clamp(abs(amount - visible_amount), 200, 500)
	#visible_amount = move_toward(visible_amount, amount, spd * delta)
	text = str(visible_amount)
	owner.experience_point = amount

func drop_experience() -> void:
	if previous_drop: previous_drop.queue_free()
	var exp_drop = experience_drop.instantiate()

	exp_drop.amount = amount
	lose(amount)
	exp_drop.global_position = owner.global_position

	get_tree().current_scene.add_child(exp_drop)
	previous_drop = exp_drop
