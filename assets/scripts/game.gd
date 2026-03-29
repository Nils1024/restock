extends Node2D

@onready var tilemap = $TileMapLayer
var noise = FastNoiseLite.new()

var mouse_press_start = Vector2.ZERO
var is_dragging = false
var drag_threshold = 10

var last_center = Vector2i.ZERO
var last_zoom = 0.0
var loaded_chunks = {}
var chunk_cache = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2.0
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cam = $Camera2D
	var center = tilemap.local_to_map(cam.get_screen_center_position())
	
	var zoom_changed = abs(cam.zoom.x - last_zoom) > 0.0001
	
	if center != last_center or zoom_changed:
		update_chunks(center)
		last_center = center
		last_zoom = cam.zoom.x
		
	cleanup(center)
		
func update_chunks(center_tile: Vector2i):
	var center_chunk = tile_to_chunk(center_tile)
	var radius = get_chunk_radius()
	
	for cx in range(center_chunk.x - radius, center_chunk.x + radius):
		for cy in range(center_chunk.y - radius, center_chunk.y + radius):
			
			var chunk_pos = Vector2i(cx, cy)
			
			if loaded_chunks.has(chunk_pos):
				continue
			
			generate_chunk(chunk_pos)
			
func generate_chunk(chunk_pos: Vector2i):
	if chunk_cache.has(chunk_pos):
		apply_chunk(chunk_cache[chunk_pos])
		loaded_chunks[chunk_pos] = true
		return
	
	var result = []
	
	for x in range(Const.World.CHUNK_SIZE):
		for y in range(Const.World.CHUNK_SIZE):
			
			var wx = chunk_pos.x * Const.World.CHUNK_SIZE + x
			var wy = chunk_pos.y * Const.World.CHUNK_SIZE + y
			
			var n = noise.get_noise_2d(wx * 0.08, wy * 0.08)
			var atlas = get_tile(n, wx, wy)
			
			result.append([Vector2i(wx, wy), atlas])
	
	chunk_cache[chunk_pos] = result
	apply_chunk(result)
	loaded_chunks[chunk_pos] = true
	
func apply_chunk(data):
	for cell in data:
		tilemap.set_cell(cell[0], 0, cell[1])
			
func get_tile(n, x, y):
	if n < -0.4:
		return Vector2i(2,0)
	elif is_near_water(x,y):
		return Vector2i(1,0)
	elif n < 0.5:
		return Vector2i(0,0)
	else:
		return Vector2i(3,0)
		
func is_near_water(x,y):
	for dx in [-1,0,1]:
		for dy in [-1,0,1]:
			if dx == 0 and dy == 0:
				continue
			
			var n = noise.get_noise_2d((x+dx)*0.08, (y+dy)*0.08)
			if n < -0.4:
				return true
			
	return false
		
func tile_to_chunk(tile: Vector2i):
	return Vector2i(
		floor(tile.x / Const.World.CHUNK_SIZE),
		floor(tile.y / Const.World.CHUNK_SIZE))
		
func cleanup(center_tile):
	var center_chunk = tile_to_chunk(center_tile)
	var radius = get_chunk_radius()
	
	for chunk in loaded_chunks.keys():
		if chunk.distance_to(center_chunk) > radius:
			unload_chunk(chunk)
			
func unload_chunk(chunk_pos):
	if not chunk_cache.has(chunk_pos):
		return
	
	for cell in chunk_cache[chunk_pos]:
		tilemap.erase_cell(cell[0])
	
	loaded_chunks.erase(chunk_pos)
	
func get_chunk_radius() -> int:
	var cam = $Camera2D
	
	var viewport_size = get_viewport_rect().size
	var visible_world_size = viewport_size * cam.zoom
	
	var tile_size = tilemap.tile_set.tile_size
	var chunk_world_size = tile_size * Const.World.CHUNK_SIZE

	var chunks_x = visible_world_size.x / chunk_world_size.x
	var chunks_y = visible_world_size.y / chunk_world_size.y

	return int(ceil(max(chunks_x, chunks_y))) + 4
	
func get_move_speed() -> float:
	var speed = 30.0
	var cam = $Camera2D
	
	speed = speed * (1.0 - cam.zoom.x)
	
	return speed
	
# TODO: Look at the DDA/Bresenham algorithm
func _input(event: InputEvent) -> void:
	# Ingame menu
	if Input.is_action_just_pressed("esc"):
		$UI/IngameMenu.visible = not $UI/IngameMenu.visible
		
	if $UI/IngameMenu.visible:
		return
	
	# Camera move for the trackpad	
	if event is InputEventPanGesture:
		var delta = event.delta
		$Camera2D.position += delta * get_move_speed()
	
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
				
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var distance = mouse_press_start.distance_to(event.position)
			
			if distance > drag_threshold:
				is_dragging = true
				
			if is_dragging:
				$Camera2D.position -= event.relative * get_move_speed()
		
	# Zoom in and out
	if Input.is_action_just_pressed("zoom_in"):
		zoom_camera(1.0 / 1.5)
	if Input.is_action_just_pressed("zoom_out"):
		zoom_camera(1.5)
		
func zoom_camera(factor):
	var cam = $Camera2D
	var new_zoom = minf(maxf((cam.zoom.x * factor), 2.0/30.0), 0.3375)
	
	var mouse_before = cam.get_global_mouse_position()
	cam.zoom = Vector2(new_zoom, new_zoom)
	var mouse_after = cam.get_global_mouse_position()
	cam.position += (mouse_before - mouse_after)
