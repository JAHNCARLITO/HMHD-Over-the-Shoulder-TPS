extends Node3D

const ZOOM_FOV := 45.0
const NORMAL_FOV := 75.0
const ZOOM_TIME := 0.3

var v := Vector2.ZERO
var sns := 0.12
var fov_tween: Tween

@onready var body: Node3D = get_parent()
@onready var cam: Camera3D = $Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("aim"):
		_zoom(true)
	if Input.is_action_just_released("aim"):
		_zoom(false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		v.y -= event.relative.x * sns
		v.x = clampf(v.x - event.relative.y * sns, -40.0, 40.0)
		rotation_degrees.x = v.x
		body.rotation_degrees.y = v.y
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _zoom(zoomed: bool) -> void:
	if fov_tween:
		fov_tween.kill()
	fov_tween = create_tween()
	fov_tween.tween_property(cam, "fov", ZOOM_FOV if zoomed else NORMAL_FOV, ZOOM_TIME)
