class_name MapObject extends CharacterBody2D

@onready var sprite : AnimatedSprite2D = $Sprite
@onready var drop_marker : Marker2D = $DropMarker
@onready var audio_emitter : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var light_occuler : LightOccluder2D = $LightOccluder2D

@export var health	:= 50.0
var health_max		:= 0.0
var health_cur 		:= 0.0

@export var destructable	:= false
@export var collidable		:= false
@export var drop_random_loot := false

@export var gravity := 300 * 60
@export var y_acc := 5

var damage_taken := 0
var falling := false

func _ready() -> void:
	if collidable:
		set_collision_layer_value(1, true)
	if destructable:
		set_collision_layer_value(8, true)
	health_max = health
	health_cur = health

	var game = Game.get_singleton()
	await game.room_loaded
	print("game.loading: "+str(game.loading));
	if game.loading || !is_in_group("Crate"):
		var save_data = game.get_data_in_room(name)
		if save_data:
			load_data(save_data)

func _physics_process(delta: float) -> void:
	falling = velocity.y != 0
	if falling && is_on_floor_only():
		Ge.EmitNoise(self, global_position + drop_marker.position, 20)
		Ge.play_audio(audio_emitter, 0, "res://SFX/Hit on wood/")
	if !is_on_floor():
		velocity.y = move_toward(velocity.y, gravity * delta, y_acc)
	move_and_slide()

func take_damage(damage: int, source) -> void:
	if damage > 0:
		Ge.play_particle(load("res://VFX/crate_particles.tscn"), global_position)
	health_cur -= damage
	var frame_count = float(sprite.sprite_frames.get_frame_count(sprite.animation))
	if health_cur > 0:
		Ge.play_audio_from_string_array(source.global_position, 0, "res://SFX/Hit on wood/")

		damage_taken = damage_taken + damage
		sprite.frame = (1 - (health_cur / health_max)) * frame_count
	else:
		sprite.frame = frame_count
		Ge.play_audio_free(0, "res://SFX/wood break.mp3")
		if drop_random_loot:
			drop_loot()

		set_collision_layer_value(1, false)
		set_collision_layer_value(8, false)
		if light_occuler: light_occuler.queue_free()
	save()
func drop_loot() -> void:
	var path = "res://Inventory/Pickup Objects"
	var array : Array = DirAccess.get_files_at(path)
	var scene = array.pick_random()
	print("scene: "+str(scene))
	var loot = load(path + "/" + scene).instantiate()
	loot.global_position = global_position
	get_tree().current_scene.add_child(loot)

func save() -> void:
	Game.get_singleton().save_data_in_room(name, {
		"health": health_cur,
		"frame": sprite.frame,
	})
func load_data(data: Dictionary) -> void:
	health_cur		= data.get("health", true)
	sprite.frame	= data.get("frame", 0)
	set_collision_layer_value(1, health_cur > 0)
	set_collision_layer_value(8, health_cur > 0)
