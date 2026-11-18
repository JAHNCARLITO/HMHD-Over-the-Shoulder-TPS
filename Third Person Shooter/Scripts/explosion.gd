extends Node3D

@export var big: bool = false

@onready var particles: CPUParticles3D = $CPUParticles3D

func _ready() -> void:
	if big:
		scale = Vector3.ONE * 2.5
		particles.amount = 24
		particles.spread = 180.0
	else:
		particles.amount = 10
		particles.spread = 60.0

	particles.emitting = true
	get_tree().create_timer(particles.lifetime + 0.2).timeout.connect(queue_free)
