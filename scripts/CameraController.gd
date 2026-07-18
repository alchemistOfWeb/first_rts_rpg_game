extends Camera2D


@export var pan_speed: float = 800.0
@export var edge_pan_enabled: bool = true
@export var edge_pan_margin: int = 24
 
@export var zoom_speed: float = 0.1
@export var zoom_min: float = 0.4
@export var zoom_max: float = 2.5
 
func _get_updated_direction():
	var dir := Vector2.ZERO
	# move by keyboard:
	dir = Vector2(
		Input.get_axis("move_left", "move_right"), 
		Input.get_axis("move_up", "move_down")
	)

	# move by mouse:
	if edge_pan_enabled and DisplayServer.window_is_focused():
		var mouse_pos := get_viewport().get_mouse_position()
		var vp_size := get_viewport_rect().size
		if mouse_pos.x <= edge_pan_margin:
			dir.x -= 1
		elif mouse_pos.x >= vp_size.x - edge_pan_margin:
			dir.x += 1
		if mouse_pos.y <= edge_pan_margin:
			dir.y -= 1
		elif mouse_pos.y >= vp_size.y - edge_pan_margin:
			dir.y += 1
		
	return dir.normalized() if (dir != Vector2.ZERO) else dir
	
func _move_camera(dir, delta):
	global_position += dir * pan_speed * delta
	
func _process(delta: float) -> void:
	_move_camera(_get_updated_direction(), delta)
	
 
 
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-zoom_speed)
 
 
func _apply_zoom(delta_zoom: float) -> void:
	var new_zoom := zoom + Vector2.ONE * delta_zoom
	zoom = new_zoom.clamp(Vector2.ONE * zoom_min, Vector2.ONE * zoom_max)

func _ready() -> void:
	pass # Replace with function body.
