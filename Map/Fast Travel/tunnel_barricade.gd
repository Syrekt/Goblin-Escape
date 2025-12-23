class_name TunnelBarricade extends CharacterBody2D

var health : float

@onready var sprite := $BarricadeSprite
@onready var sfx_emitter : FmodEventEmitter2D = $SFXEmitter

func take_damage(damage: int, source=null) -> void:
	# Play sfx and particle effects
	if source:
		if damage == 0:
			sfx_emitter.set_parameter("State", "WoodTanked")
		elif damage > 0:
			Ge.play_particle(load("res://VFX/crate_particles.tscn"), global_position)
			sfx_emitter.set_parameter("State", "WoodDamaged")

	health -= damage

	# Set frame
	var frame_count = float(sprite.sprite_frames.get_frame_count(sprite.animation))

	if health <= 0: # Break the barricade
		if damage > 0 && source:
			sfx_emitter.set_parameter("State", "WoodDestroyed")
		set_collision_layer_value(16, false)
		sprite.frame = frame_count
	else: # Update frame
		sprite.frame = (1 - (health / owner.barricade_health)) * (frame_count - 1)

	sfx_emitter.play()
	owner.save()
