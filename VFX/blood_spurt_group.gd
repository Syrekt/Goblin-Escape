extends Node2D

@export var particles: Array[GPUParticles2D]

var finished_count := 0

func _ready() -> void:
	for particle in particles:
		particle.finished.connect(_on_finished.bind(particle))

func _process(delta: float) -> void:
	if finished_count == particles.size():
		queue_free()

func _on_finished(particle: GPUParticles2D) -> void:
	particle.queue_free()
	finished_count += 1
