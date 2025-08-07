extends CanvasLayer

@onready var input_timer := $Timer
@onready var continue_prompt := $ContinuePrompt

func _ready() -> void:
	$Page1.show()
	$Page2.hide()
	input_timer.start()

func _process(delta: float) -> void:
	continue_prompt.visible = input_timer.is_stopped()
	if input_timer.is_stopped() && Input.is_action_just_pressed("stance"):
		if $Page1.visible:
			$Page1.hide()
			$Page2.show()
			input_timer.start()
		elif $Page2.visible:
			queue_free()
