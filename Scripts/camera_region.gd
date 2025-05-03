extends Area2D

@onready var boundary : CollisionShape2D = $CollisionShape2D

var limit_top : int
var limit_bottom : int
var limit_left : int
var limit_right : int


func _ready() -> void:
	var shape : Shape2D = boundary.shape
	boundary.visible = false
	var rect = shape.get_rect()
	var size = rect.size
	var pos = rect.position
	limit_left = global_position.x + boundary.global_position.x + size.x/2
	limit_top = global_position.y + boundary.global_position.y + size.y/2
	limit_right = limit_left + size.x/2
	limit_bottom = limit_top + size.y/2

func _process(delta: float) -> void:
	var shape : Shape2D = boundary.shape
	boundary.visible = false
	var rect : Rect2 = shape.get_rect()
	var size = rect.size
	limit_left		= global_position.x + rect.position.x
	limit_top		= global_position.y + rect.position.y
	limit_right 	= global_position.x + rect.end.x
	limit_bottom	= global_position.y + rect.end.y

func _on_body_entered(body: Node2D) -> void:
	body.camera.region = self


func _on_body_exited(body: Node2D) -> void:
	if body.camera.region == self:
		body.camera.region = null
