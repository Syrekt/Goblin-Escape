extends Interaction

var tween : Tween
@onready var sprite : Sprite2D = $Sprite
@export var pickup_sound : String
@export var item : InventoryItem

func _ready() -> void:
	sprite.texture = item.icon
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_SINE).set_loops(-1)
	tween.tween_property(sprite, "position", Vector2(0, -6), 1)
	tween.tween_property(sprite, "position", Vector2(0, 0), 1)

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.inventory_panel.inventory.item_add(item)
		var text = "[img]" + sprite.texture.resource_path + "[/img]" + item.name
		Ge.popup_text(player.global_position, text)
		Ge.play_audio_free(0, pickup_sound)
		queue_free()
