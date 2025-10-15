extends PlayerState

var buff_scene = preload("res://Objects/buff.tscn")
var debuff_sprite = preload("res://UI/Buffs/death.png")

func enter(previous_state_name: String, data := {}) -> void:
	print("Kalin Recovers")
	player.call_deferred("update_animation", name)
	player.can_have_sex = false
	player.unconscious = false

	print("add death's door debuff")
	var buff = buff_scene.instantiate()
	buff.texture = debuff_sprite
	buff.effect = "death's door"
	player.buff_container.add_child(buff)
	buff.setup(1, -1)
