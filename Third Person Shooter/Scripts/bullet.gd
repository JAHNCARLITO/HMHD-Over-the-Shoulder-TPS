extends CharacterBody3D

const SPEED := 50.0
const LIFETIME := 3.0

func _ready() -> void:
	# Net: delete the bullet if it never hits anything
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	var motion := -global_transform.basis.z * SPEED * delta
	var collision := move_and_collide(motion)
	if collision:
		queue_free()   # hit something
