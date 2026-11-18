extends Control

const COLOR_IDLE := Color(1, 1, 1, 0.9)
const COLOR_ENEMY := Color(1, 0.2, 0.2, 1)


func _ready() -> void:
	add_to_group("crosshair")
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func update_reticle(screen_pos: Vector2, over_enemy: bool) -> void:
	position = screen_pos - size * 0.5
	modulate = COLOR_ENEMY if over_enemy else COLOR_IDLE
