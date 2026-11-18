extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const BULLET := preload("res://Scenes/bullet.tscn")
const BGM := preload("res://Audio/bgm.mp3")
const SHOOT_SFX := preload("res://Audio/shoot.mp3")
const DASH_SFX := preload("res://Audio/dash.mp3")
const FIRE_DELAY := 0.3
const RAY_LENGTH := 200.0
const MIN_AIM_DISTANCE := 0.5

const DASH_SPEED := 30.0
const DASH_DURATION := 0.18  
const DASH_COOLDOWN := 1.0

var shoot_timer := 0.0
var aim_point := Vector3.ZERO
var aiming_at_enemy := false
var crosshair = null

var dash_time_left := 0.0
var dash_cooldown_left := 0.0
var dash_dir := Vector3.ZERO
var is_dashing := false

@onready var gun: Node3D = $Machina
@onready var pos: Node3D = $Machina/pos
@onready var cam: Camera3D = $Head/Camera3D


func _ready() -> void:
	add_to_group("player")
	Sfx.play_loop(BGM, get_tree(), -12.0)
	_ensure_input_actions()
	aim_point = cam.global_position - cam.global_transform.basis.z * RAY_LENGTH

func _ensure_input_actions() -> void:
	_ensure_key_action("move_forward", KEY_W)
	_ensure_key_action("move_back", KEY_S)
	_ensure_key_action("move_left", KEY_A)
	_ensure_key_action("move_right", KEY_D)
	_ensure_key_action("jump", KEY_SPACE)
	_ensure_key_action("dash", KEY_E)
	_set_mouse_action("shoot", MOUSE_BUTTON_LEFT)
	_set_mouse_action("aim", MOUSE_BUTTON_RIGHT)


func _ensure_key_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if InputMap.action_get_events(action).is_empty():
		var ev := InputEventKey.new()
		ev.physical_keycode = keycode
		InputMap.action_add_event(action, ev)


func _set_mouse_action(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	dash_cooldown_left = maxf(dash_cooldown_left - delta, 0.0)
	if Input.is_action_just_pressed("dash") and dash_cooldown_left <= 0.0 and dash_time_left <= 0.0:
		dash_dir = direction if direction != Vector3.ZERO else -transform.basis.z
		Sfx.play(DASH_SFX, get_tree())
		dash_time_left = DASH_DURATION
		dash_cooldown_left = DASH_COOLDOWN

	if dash_time_left > 0.0:
		dash_time_left -= delta
		is_dashing = true
		velocity = dash_dir * DASH_SPEED
	else:
		if is_dashing:
			is_dashing = false
			velocity.x = 0.0
			velocity.z = 0.0

		velocity += get_gravity() * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)
			velocity.z = move_toward(velocity.z, 0.0, SPEED)

	shoot_timer -= delta
	if Input.is_action_just_pressed("shoot") and shoot_timer <= 0.0 and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		shoot()
		shoot_timer = FIRE_DELAY

	move_and_slide()


func _process(_delta: float) -> void:
	_update_aim_point()
	_aim_gun()
	_update_crosshair()


func _update_aim_point() -> void:
	var forward := -cam.global_transform.basis.z
	var offset := maxf((gun.global_position - cam.global_position).dot(forward), 0.0)
	var from := cam.global_position + forward * offset
	var to := cam.global_position + forward * RAY_LENGTH

	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)

	if hit:
		aim_point = hit["position"]
		var collider := hit.get("collider") as Node
		aiming_at_enemy = collider != null and collider.is_in_group("enemy")
	else:
		aim_point = to
		aiming_at_enemy = false


func _aim_gun() -> void:
	var dir := aim_point - gun.global_position
	if dir.length() < MIN_AIM_DISTANCE:
		dir = -cam.global_transform.basis.z 
	gun.look_at(gun.global_position + dir, _safe_up(dir))


func _update_crosshair() -> void:
	if not is_instance_valid(crosshair):
		crosshair = get_tree().get_first_node_in_group("crosshair")
		if crosshair == null:
			return
	crosshair.update_reticle(cam.unproject_position(aim_point), aiming_at_enemy)


func shoot() -> void:
	Sfx.play(SHOOT_SFX, get_tree(), -8.0)
	var muzzle := pos.global_position

	var chest := global_position + Vector3(0.0, gun.position.y, 0.0)
	var reach := muzzle + (muzzle - chest).normalized() * 0.1
	var query := PhysicsRayQueryParameters3D.create(chest, reach)
	query.exclude = [get_rid()]
	var blocked := get_world_3d().direct_space_state.intersect_ray(query)

	var b = BULLET.instantiate()
	b.add_to_group("bullet")
	b.add_collision_exception_with(self)
	get_parent().add_child(b)

	if blocked:
		b.global_position = blocked["position"]
		b.impact(blocked["position"], blocked["normal"], blocked.get("collider"))
		return

	b.global_position = muzzle

	var dir := aim_point - muzzle
	if dir.length() < 0.1:
		dir = -gun.global_transform.basis.z
	b.look_at(muzzle + dir, _safe_up(dir))


func _safe_up(dir: Vector3) -> Vector3:
	if absf(dir.normalized().dot(Vector3.UP)) < 0.99:
		return Vector3.UP
	return Vector3.FORWARD
