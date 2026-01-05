extends Sprite2D

var tween : Tween
var item
var instantiated := false
@export var item_name : String
@export_enum ("General", "JournalPage") var loot_type : String = "General"

func _ready() -> void:
	# Load item pickup
	print("instantiated: "+str(instantiated))
	if !instantiated:
		var game = Game.get_singleton()
		await game.room_loaded
		if game.loading:
			var save_data = game.get_data_in_room(name)
			if save_data:
				queue_free()

	item = ImportData.item_data.get(item_name)
	print("item: "+str(item))
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_SINE).set_loops(-1)
	tween.tween_property(self, "offset", Vector2(0, -6), 1)
	tween.tween_property(self, "offset", Vector2(0, 0), 1)
