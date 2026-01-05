class_name MapObject extends CharacterBody2D

@onready var sprite : AnimatedSprite2D = $Sprite
@onready var drop_marker : Marker2D = $DropMarker
@onready var light_occuler : LightOccluder2D = $LightOccluder2D
@onready var sfx_emitter : FmodEventEmitter2D = $SFXEmitter

@export var health	:= 50.0
var health_max		:= 0.0
var health_cur 		:= 0.0

@export_enum ("Wood") var material_type : String = "Wood"
@export var persistent		:= false
@export var destructable	:= false
@export var collidable		:= false
@export var drop_random_loot:= false

@export var gravity := 300 * 60
@export var y_acc := 5

@export var debug := false

@export var random_drops : Array[PackedScene]

var spawn_fall_protection := true

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
	var save_data = game.get_data_in_room(name)
	if save_data:
		load_data(save_data)

func _physics_process(delta: float) -> void:
	if is_on_floor(): spawn_fall_protection = false

	move_and_slide()

	if !spawn_fall_protection && health_cur > 0 && falling && is_on_floor_only():
		Ge.EmitNoise(self, global_position + drop_marker.position, 20)
		sfx_emitter.set_parameter("State", "WoodTanked")
		sfx_emitter.play()
	if !is_on_floor() && health_cur <= 0:
		velocity.y = move_toward(velocity.y, gravity * delta, y_acc)

	falling = velocity.y != 0

func take_damage(damage: int, source) -> void:
	if damage > 0:
		Ge.play_particle(load("res://VFX/crate_particles.tscn"), global_position)
	health_cur -= damage
	if damage == 0: sfx_emitter.set_parameter("State", "WoodTanked")
	else:			sfx_emitter.set_parameter("State", "WoodDamaged")
	var frame_count = float(sprite.sprite_frames.get_frame_count(sprite.animation))
	if health_cur > 0:
		damage_taken = damage_taken + damage
		sprite.frame = min(frame_count - 2, (1 - (health_cur / health_max)) * frame_count)
	else:
		sprite.frame = frame_count
		sfx_emitter.set_parameter("State", "WoodDestroyed")
		if drop_random_loot && randi() % 2:
			drop_loot()

		if collidable:
			set_collision_layer_value(1, true)
		set_collision_layer_value(8, false)
		set_collision_layer_value(13, false)
		for child in get_children():
			if child is LightOccluder2D:
				child.queue_free()
	sfx_emitter.play()
	save()
func drop_loot() -> void:
	print("Drop loot")
	var scene : PackedScene = random_drops.pick_random()
	print("scene: "+str(scene))
	var loot = scene.instantiate()
	loot.instantiated = true
	loot.global_position = global_position
	get_tree().current_scene.add_child(loot)

func save() -> void:
	Game.get_singleton().save_data_in_room(name, {
		"health": health_cur,
		"frame": sprite.frame,
	})
	print(name + " saved.")
func load_data(data: Dictionary) -> void:
	print("Load " + name)
	health_cur		= data.get("health", true)
	if health_cur <= 0:
		if !persistent: health_cur = health_max
		else: sprite.frame = data.get("frame", 0)
	else:
		sprite.frame	= data.get("frame", 0)
	if collidable:
		set_collision_layer_value(1, health_cur > 0)
	set_collision_layer_value(8, health_cur > 0)
	set_collision_layer_value(13, health_cur > 0)
