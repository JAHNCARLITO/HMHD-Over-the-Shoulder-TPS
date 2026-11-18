extends CharacterBody3D

const SPEED := 40.0
const LIFETIME := 3.0
const EXPLOSION := preload("res://Scenes/explosion.tscn")

func _ready() -> void:
	add_to_group("bullet")
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	var motion := -global_transform.basis.z * SPEED * delta
	var collision := move_and_collide(motion)
	if collision:
		_on_hit(collision)

func _on_hit(collision: KinematicCollision3D) -> void:
	impact(collision.get_position(), collision.get_normal(), collision.get_collider())


func impact(hit_pos: Vector3, hit_normal: Vector3, collider: Object) -> void:
	if collider and collider.is_in_group("enemy") and collider.has_method("take_damage"):
		collider.take_damage(1)

	_spawn_explosion(hit_pos, hit_normal)
	queue_free()

func _spawn_explosion(pos: Vector3, normal: Vector3) -> void:
	var fx := EXPLOSION.instantiate()
	fx.big = false
	var ref := Vector3.FORWARD if absf(normal.dot(Vector3.FORWARD)) < 0.99 else Vector3.RIGHT
	var x_axis := normal.cross(ref).normalized()
	var z_axis := x_axis.cross(normal).normalized()
	var world_xform := Transform3D(Basis(x_axis, normal, z_axis), pos)

	var scene := get_tree().current_scene as Node3D
	fx.transform = scene.global_transform.affine_inverse() * world_xform
	scene.add_child(fx)
