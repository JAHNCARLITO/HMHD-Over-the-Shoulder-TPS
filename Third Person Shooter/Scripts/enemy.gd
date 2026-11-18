extends CharacterBody3D

@export var health: int = 3
const EXPLOSION := preload("res://Scenes/explosion.tscn")
const HURT_SFX := preload("res://Audio/hurt.mp3")
const DEATH_SFX := preload("res://Audio/death.mp3")

const STRAFE_SPEED := 5.0
const ARENA_HALF := 12.0

var strafe_dir := 1.0
var strafe_timer := 0.0


func _ready() -> void:
	add_to_group("enemy")
	strafe_dir = 1.0 if randf() < 0.5 else -1.0
	strafe_timer = randf_range(0.5, 2.0)


func _physics_process(delta: float) -> void:
	strafe_timer -= delta
	if strafe_timer <= 0.0 or is_on_wall():
		strafe_dir = -strafe_dir
		strafe_timer = randf_range(1.0, 2.5)

	var side := global_transform.basis.x * strafe_dir * STRAFE_SPEED
	velocity.x = side.x
	velocity.z = side.z

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity += get_gravity() * delta

	move_and_slide()


func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		_die()
	else:
		Sfx.play(HURT_SFX, get_tree(), -4)


func _die() -> void:
	Sfx.play(DEATH_SFX, get_tree(), -10.0)
	var fx := EXPLOSION.instantiate()
	fx.big = true
	var scene := get_tree().current_scene as Node3D
	var world_pos := global_position + Vector3(0, 0.9, 0)
	fx.position = scene.global_transform.affine_inverse() * world_pos
	scene.add_child(fx)
	_respawn()
	queue_free()


func _respawn() -> void:
	var e: CharacterBody3D = load(scene_file_path).instantiate()
	get_parent().add_child(e)

	var player := get_tree().get_first_node_in_group("player") as Node3D
	e.global_position = Vector3(randf_range(-ARENA_HALF, ARENA_HALF), 0.25, randf_range(-ARENA_HALF, ARENA_HALF))
		
