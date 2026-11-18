extends Node3D

@onready var chb3d = $".."
@onready var hd = $"."

var v = Vector3()
var sns= 0.12

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hd.rotation_degrees.x = v.x
	chb3d.rotation_degrees.y = v.y
	
	if Input.is_action_just_pressed("aim"):
		$Camera3D/AnimationPlayer.play("aim zoom")
	if Input.is_action_just_released("aim"):
		$Camera3D/AnimationPlayer.play_backwards("aim zoom")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		v.y -= (event.relative.x * sns)
		v.x -= (event.relative.y * sns)
		v.x = clamp(v.x, -40, 40)
	
	
