extends Node2D

@export var snap_to_pixel : bool
@export var transition_type : PhantomCameraTween.TransitionType
@export var ease_type : PhantomCameraTween.EaseType

@export var follow_damping : bool
@export var follow_damping_value : Vector2

@export var pcam_list : Array[PhantomCamera2D]
@export var area_list : Array[Area2D]


func _ready() -> void:
	for i in area_list.size():
		print("i: "+str(i))
		var area = area_list[i]
		area.body_entered.connect(_on_body_entered.bind(pcam_list[i]))
		area.body_exited.connect(_on_body_exited.bind(pcam_list[i]))
		area.set_collision_layer_value(1, false)
		area.set_collision_mask_value(1, false)
		area.set_collision_mask_value(2, true)

		var pcam : PhantomCamera2D = pcam_list[i]
		pcam.tween_resource.transition = transition_type
		pcam.tween_resource.ease = ease_type
		pcam.snap_to_pixel = snap_to_pixel
		pcam.follow_damping = follow_damping
		pcam.follow_damping_value = follow_damping_value
		pcam.draw_limits = true
		pcam.follow_mode = pcam.FollowMode.SIMPLE
		pcam.follow_target = %Kalin
		pcam.limit_target = area.get_child(0).get_path()

func _on_body_entered(body: Node2D, pcam: PhantomCamera2D) -> void:
	print("Area body entered: " + str(pcam))
	if body is Player:
		pcam.set_follow_target(body)
		pcam.set_priority(20)
		body.pcam = pcam

func _on_body_exited(body: Node2D, pcam: PhantomCamera2D) -> void:
	print("Area body exited: " + str(pcam))
	if body is Player:
		pcam.set_priority(0)
		pcam.set_follow_target(null)
		body.pcam = null
