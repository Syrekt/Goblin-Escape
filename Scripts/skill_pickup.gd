extends Sprite2D

@export var skill_name		: String
@export var pickup_sound	: String = "res://SFX/Notes Scrunched In Wallet.wav"

var tween : Tween

func _ready() -> void:
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_SINE).set_loops(-1)
	tween.tween_property(self, "offset", Vector2(0, -6), 1)
	tween.tween_property(self, "offset", Vector2(0, 0), 1)
