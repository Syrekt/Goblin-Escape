class_name Portal extends Interaction

@export var inert := true

@onready var background_sprite : AnimatedSprite2D = $BackgroundSprite
@onready var base_sprite : AnimatedSprite2D = $BaseSprite
@onready var teleport_menu : CanvasLayer = $TeleportMenu

func _ready() -> void:
	teleport_menu.hide()
	var game = Game.get_singleton()
	await game.room_loaded
	var save_data = game.get_data_in_room(name)
	if save_data:
		load_data(save_data)
	if inert:
		background_sprite.hide()
	

func update(player: Player) -> void:
	if player.just_pressed("back"):
		if teleport_menu.visible:
			teleport_menu.hide()
			return

	if player.just_pressed("interact"):
		if teleport_menu.visible:
			print("interact with teleport menu")
		else:
			if inert:
				activate()
			else:
				player.think("Need to activate another portal first.")
				#teleport_menu.show()
		return

	if teleport_menu.visible && Input.is_action_just_pressed("back"):
		teleport_menu.hide()
		return

	if inert:
		return

func activate() -> void:
	inert = false
	$Light.enabled = true
	base_sprite.play("active")
	background_sprite.show()
	background_sprite.play("activating")
	Game.get_singleton().save_data_in_room(name, {"inert": false})
func load_data(data: Dictionary) -> void:
	inert = data.get(inert, true)
	if !inert:
		base_sprite.play("active")
		background_sprite.play("active")
		$Light.enabled = true


func _on_background_sprite_animation_finished() -> void:
	print("animation: "+str(background_sprite.animation));
	if background_sprite.animation == "activating":
		background_sprite.play("active")
