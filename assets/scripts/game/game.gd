extends Node2D

@onready var tilemap = $TileMapLayer
@onready var world_manager: WorldManager = $WorldManager
@onready var cam = $Camera2D

var mouse_press_start: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var drag_threshold: int = 10
var is_magnifying: bool = false
var last_magnify_factor: float = 0.0

var last_center: Vector2i = Vector2i.ZERO
var last_zoom: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_manager.tilemap = tilemap
	update_camera_bounds()
	
	await UtilityService.wait(1)
	$UI/Tutorial.offset = Vector2(400, 200)
	$UI/Tutorial.add_text_to_queue("Welcome to Restock")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var center = tilemap.local_to_map(cam.get_screen_center_position())
	var zoom_changed = abs(cam.zoom.x - last_zoom) > 0.0001
	
	if center != last_center or zoom_changed:
		var radius = get_chunk_radius()
		world_manager.update_visible_chunks(center, radius + 2)
		world_manager.cleanup_distant_chunks(center, radius + 3)
		last_center = center
		last_zoom = cam.zoom.x
		update_camera_bounds()
	
func update_camera_bounds() -> void:
	var min_pos = tilemap.map_to_local(Vector2i(Const.World.MIN_WORLD_COORD, Const.World.MIN_WORLD_COORD))
	var max_pos = tilemap.map_to_local(Vector2i(Const.World.MAX_WORLD_COORD, Const.World.MAX_WORLD_COORD))
	
	cam.limit_left = int(min_pos.x)
	cam.limit_top = int(min_pos.y)
	cam.limit_right = int(max_pos.x)
	cam.limit_bottom = int(max_pos.y)
	
func get_chunk_radius() -> int:
	var viewport_size = get_viewport_rect().size
	var tile_size = tilemap.tile_set.tile_size
	
	var visible_world_size = viewport_size * cam.zoom
	var chunk_world_size = tile_size * Const.World.CHUNK_SIZE

	var chunks_x = visible_world_size.x / chunk_world_size.x
	var chunks_y = visible_world_size.y / chunk_world_size.y

	return int(ceil(max(chunks_x, chunks_y) / 2.0)) + 2
	
func get_move_speed() -> float:
	var base_speed = 500.0
	return base_speed * pow(cam.zoom.x, 0.8)
	
# TODO: Look at the DDA/Bresenham algorithm
func _input(event: InputEvent) -> void:
	# Ingame menu
	if Input.is_action_just_pressed("esc"):
		$UI/IngameMenu.visible = not $UI/IngameMenu.visible
		
	if $UI/IngameMenu.visible:
		return
	
	# Camera move for the trackpad	
	if event is InputEventPanGesture:
		cam.position += event.delta * get_move_speed()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_press_start = event.position
			is_dragging = false
		else:
			var distance = mouse_press_start.distance_to(event.position)
			
			if distance < drag_threshold:
				# Click
				var mouse_pos = get_global_mouse_position()
				var cell = $TileMapLayer.local_to_map($TileMapLayer.to_local(mouse_pos))
				print("Clicked:", cell)
			else:
				is_dragging = false
				
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var distance = mouse_press_start.distance_to(event.position)
		
		if distance > drag_threshold:
			is_dragging = true
			
		if is_dragging:
			cam.position -= event.relative * get_move_speed()
		
	# Zoom in and out
	if Input.is_action_just_pressed("zoom_in"):
		zoom_camera(1.0 / 1.5)
	if Input.is_action_just_pressed("zoom_out"):
		zoom_camera(1.5)
		
	if event is InputEventMagnifyGesture:
		if not is_magnifying:
			last_magnify_factor = event.factor
			is_magnifying = true
			return
		
		var delta = event.factor / last_magnify_factor
		last_magnify_factor = event.factor
		zoom_camera(1.0 / delta)
	if event is InputEventMagnifyGesture and event.factor == 1.0:
		is_magnifying = false
		last_magnify_factor = 1.0
		
func zoom_camera(factor):
	var old_zoom = cam.zoom.x
	var new_zoom = clamp(old_zoom * factor, 2.0/30.0, 0.3375)
	
	if is_equal_approx(old_zoom, new_zoom):
		return
	
	var mouse_before = cam.get_global_mouse_position()
	cam.zoom = Vector2(new_zoom, new_zoom)
	var mouse_after = cam.get_global_mouse_position()
	
	cam.position += (mouse_before - mouse_after)
