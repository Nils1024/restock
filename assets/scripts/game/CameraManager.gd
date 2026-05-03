extends Camera2D

class_name CameraManager

@export var tilemap: TileMapLayer

var _mouse_press_start: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _is_magnifying: bool = false
var _last_magnify_factor: float = 0.0

func update_bounds() -> void:
	var min_pos = tilemap.map_to_local(Vector2i(Const.World.MIN_WORLD_COORD, Const.World.MIN_WORLD_COORD))
	var max_pos = tilemap.map_to_local(Vector2i(Const.World.MAX_WORLD_COORD, Const.World.MAX_WORLD_COORD))
	
	limit_left = int(min_pos.x)
	limit_top = int(min_pos.y)
	limit_right = int(max_pos.x)
	limit_bottom = int(max_pos.y)
	
	_clamp_to_limits()
	
func _clamp_to_limits() -> void:
	var half_view = get_viewport_rect().size / 2 / zoom
	position.x = clamp(position.x, limit_left + half_view.x, limit_right - half_view.x)
	position.y = clamp(position.y, limit_top + half_view.y, limit_bottom - half_view.y)
	
func get_chunk_radius() -> int:
	var viewport_size = get_viewport_rect().size
	var tile_size = tilemap.tile_set.tile_size
	
	var visible_world_size = viewport_size * zoom
	var chunk_world_size = tile_size * Const.World.CHUNK_SIZE

	var chunks_x = visible_world_size.x / chunk_world_size.x
	var chunks_y = visible_world_size.y / chunk_world_size.y

	return int(ceil(max(chunks_x, chunks_y) / 2.0)) + 2
	
func get_move_speed() -> float:
	var base_speed = 500.0
	return base_speed * pow(zoom.x, 0.8)
	
# TODO: Look at the DDA/Bresenham algorithm
func handle_input(event: InputEvent) -> void:
	# Camera move for trackpad	
	if event is InputEventPanGesture:
		position += event.delta * get_move_speed()
		_clamp_to_limits()
	
	# Camera move and click for mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_mouse_press_start = event.position
			_is_dragging = false
		else:
			var distance = _mouse_press_start.distance_to(event.position)
			
			if distance < Const.Camera.DRAG_THRESHOLD:
				# Click
				var mouse_pos = get_global_mouse_position()
				var cell = tilemap.local_to_map(tilemap.to_local(mouse_pos))
				print("Clicked:", cell)
			else:
				_is_dragging = false
		
	# Camera move for mouse		
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var distance = _mouse_press_start.distance_to(event.position)
		
		if distance > Const.Camera.DRAG_THRESHOLD:
			_is_dragging = true
			
		if _is_dragging:
			position -= event.relative * get_move_speed()
			_clamp_to_limits()
		
	if event is InputEventMagnifyGesture:
		_handle_trackpad_zoom(event)
	else:
		_handle_zoom(event)
		
func _handle_trackpad_zoom(event: InputEvent) -> void:
	if not _is_magnifying:
		_last_magnify_factor = event.factor
		_is_magnifying = true
		return
		
	var delta = event.factor / _last_magnify_factor
	_last_magnify_factor = event.factor
	zoom_camera(1.0 / delta)
		
	if event.factor == 1.0:
		_is_magnifying = false
		_last_magnify_factor = 1.0
		
func _handle_zoom(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom_camera(1.0 / 1.5)
	if event.is_action_pressed("zoom_out"):
		zoom_camera(1.5)
		
func zoom_camera(factor) -> void:
	var old_zoom = zoom.x
	var new_zoom = clamp(old_zoom * factor, 2.0/30.0, 0.3375)
	
	if is_equal_approx(old_zoom, new_zoom):
		return
	
	var mouse_before = get_global_mouse_position()
	zoom = Vector2(new_zoom, new_zoom)
	var mouse_after = get_global_mouse_position()
	
	position += (mouse_before - mouse_after)
	_clamp_to_limits()
