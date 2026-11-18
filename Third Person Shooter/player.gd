extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const BULLET = preload("res://bullet.tscn")
const FIRE_DELAY := 0.3   # seconds between shots
var shoot_timer := 0.0

@onready var pos: Node3D = $Machina/pos
@onready var cam: Camera3D = $Head/Camera3D


func _physics_process(delta: float) -> void:
	# Gravity every frame so we stay pressed to the floor
	velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement (swap these action names for your own Input Map actions)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	shoot_timer -= delta
	if Input.is_action_just_pressed("shoot") and shoot_timer <= 0.0:
		shoot()
		shoot_timer = FIRE_DELAY

	move_and_slide()


func shoot() -> void:
	var b = BULLET.instantiate()
	b.add_collision_exception_with(self)   # bullet ignores the player
	get_parent().add_child(b)              # must be in the tree before setting global values
	b.global_position = pos.global_position

	# Aim at whatever the camera is pointing at
	var from := cam.global_position
	var to := from - cam.global_transform.basis.z * 200.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var target: Vector3 = hit.position if hit else to
	b.look_at(target)
