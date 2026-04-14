extends Node2D

@onready var tilemap = $TileMapLayer

var elevation_noise: Noise = FastNoiseLite.new()
var temp_noise: Noise = FastNoiseLite.new()
var humidity_noise: Noise = FastNoiseLite.new()

var mouse_press_start: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var drag_threshold: int = 10
var is_magnifying: bool = false
var last_magnify_factor: float = 0.0

var last_center: Vector2i = Vector2i.ZERO
var last_zoom: float = 0.0
var loaded_chunks: Dictionary = {}
var chunk_cache: Dictionary = {}

var active_threads: Dictionary = {}
var chunk_queue: Array[Vector2i] = []

enum biomes {
	SNOW,
	TUNDRA,
	DESERT,
	FOREST,
	GRASS
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	elevation_noise.seed = randi()
	elevation_noise.frequency = 0.05
	elevation_noise.fractal_octaves = 4
	elevation_noise.fractal_gain = 0.5
	elevation_noise.fractal_lacunarity = 2.0
	elevation_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	temp_noise.seed = randi() + 1
	temp_noise.frequency = 0.02
	temp_noise.fractal_octaves = 3
	temp_noise.fractal_gain = 0.5
	temp_noise.fractal_lacunarity = 2.0
	temp_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	humidity_noise.seed = randi() + 2
	humidity_noise.frequency = 0.025
	humidity_noise.fractal_octaves = 3
	humidity_noise.fractal_gain = 0.5
	humidity_noise.fractal_lacunarity = 2.0
	humidity_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	update_camera_bounds()
	
	await UtilityService.wait(1)
	
	$UI/Tutorial.offset = Vector2(400, 200)
	$UI/Tutorial.add_text_to_queue("Welcome to Restock")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cam = $Camera2D
	var center = tilemap.local_to_map(cam.get_screen_center_position())
	
	var zoom_changed = abs(cam.zoom.x - last_zoom) > 0.0001
	
	if center != last_center or zoom_changed:
		update_chunks(center)
		last_center = center
		last_zoom = cam.zoom.x
		update_camera_bounds()
		
	process_thread_queue()
	collect_finished_threads()
	cleanup(center)
	
func update_camera_bounds() -> void:
	var cam = $Camera2D
	var tile_size = tilemap.tile_set.tile_size
	
	var min_pos = tilemap.map_to_local(Vector2i(Const.World.MIN_WORLD_COORD, Const.World.MIN_WORLD_COORD))
	var max_pos = tilemap.map_to_local(Vector2i(Const.World.MAX_WORLD_COORD, Const.World.MAX_WORLD_COORD))
	
	cam.limit_left = int(min_pos.x)
	cam.limit_top = int(min_pos.y)
	cam.limit_right = int(max_pos.x)
	cam.limit_bottom = int(max_pos.y)
		
func update_chunks(center_tile: Vector2i):
	var center_chunk = tile_to_chunk(center_tile)
	var radius = get_chunk_radius()
	var load_radius = radius + 2
	var needed_chunks: Array[Vector2i] = []
	
	for cx in range(center_chunk.x - load_radius, center_chunk.x + load_radius + 1):
		for cy in range(center_chunk.y - load_radius, center_chunk.y + load_radius + 1):
			var chunk_pos = Vector2i(cx, cy)
			
			if loaded_chunks.has(chunk_pos) or active_threads.has(chunk_pos):
				continue
				
			needed_chunks.append(chunk_pos)
	
	needed_chunks.sort_custom(func(a, b):
		return a.distance_to(center_chunk) < b.distance_to(center_chunk)
	)
	
	for chunk in needed_chunks:
		if not chunk_queue.has(chunk):
			chunk_queue.append(chunk)
			
func generate_chunk_async(chunk_pos: Vector2i) -> void:
	var thread: Thread = Thread.new()
	active_threads[chunk_pos] = thread
	thread.start(_thread_generate.bind(chunk_pos))

func _thread_generate(chunk_pos: Vector2i) -> Array:
	var result: Array = []
	
	for x in range(Const.World.CHUNK_SIZE):
		for y in range(Const.World.CHUNK_SIZE):
			var wx = chunk_pos.x * Const.World.CHUNK_SIZE + x
			var wy = chunk_pos.y * Const.World.CHUNK_SIZE + y
			
			if wx < Const.World.MIN_WORLD_COORD or wx > Const.World.MAX_WORLD_COORD or wy < Const.World.MIN_WORLD_COORD or wy > Const.World.MAX_WORLD_COORD:
				continue
				
			var elevation = elevation_noise.get_noise_2d(wx * 0.08, wy * 0.08)
			var temp = temp_noise.get_noise_2d(wx * 0.01, wy * 0.01)
			var humidity = humidity_noise.get_noise_2d(wx * 0.01, wy * 0.01)
			
			var atlas = get_tile(elevation, wx, wy)
			result.append([Vector2i(wx, wy), atlas])
	
	return result
	
func process_thread_queue() -> void:
	while active_threads.size() < Const.config.MAX_THREADS and not chunk_queue.is_empty():
		var chunk_pos = chunk_queue.pop_front()
		
		var thread: Thread = Thread.new()
		active_threads[chunk_pos] = thread
		thread.start(_thread_generate.bind(chunk_pos))
		
func collect_finished_threads():
	for chunk_pos in active_threads.keys().duplicate():
		var thread: Thread = active_threads[chunk_pos]
		
		if not thread.is_alive():
			var result: Array = thread.wait_to_finish()
			active_threads.erase(chunk_pos)
			
			if result.is_empty():
				continue
			
			chunk_cache[chunk_pos] = result
			apply_chunk(result)
			loaded_chunks[chunk_pos] = true
	
func apply_chunk(data):
	for cell in data:
		tilemap.set_cell(cell[0], 0, cell[1])
		
func get_biome(temperature: float, humidity: float) -> biomes:
	if temperature < -0.3:
		return biomes.SNOW
	else:
		return biomes.GRASS
			
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
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
				
			var nx = x + dx
			var ny = y + dy
			
			if nx < Const.World.MIN_WORLD_COORD or nx > Const.World.MAX_WORLD_COORD or ny < Const.World.MIN_WORLD_COORD or ny > Const.World.MAX_WORLD_COORD:
				continue
			
			var n = elevation_noise.get_noise_2d((x+dx)*0.08, (y+dy)*0.08)
			if n < -0.4:
				return true
			
	return false
		
func tile_to_chunk(tile: Vector2i):
	return Vector2i(
		floor(float(tile.x) / Const.World.CHUNK_SIZE),
		floor(float(tile.y) / Const.World.CHUNK_SIZE))
		
func cleanup(center_tile):
	var center_chunk = tile_to_chunk(center_tile)
	var radius = get_chunk_radius()
	var unload_radius = radius + 3
	
	for chunk in loaded_chunks.keys().duplicate():
		if chunk.distance_to(center_chunk) > unload_radius:
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

	return int(ceil(max(chunks_x, chunks_y) / 2.0)) + 2
	
func get_move_speed() -> float:
	var base_speed = 500.0
	var cam = $Camera2D
	
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
	var cam = $Camera2D
	
	var old_zoom = cam.zoom.x
	var new_zoom = clamp(old_zoom * factor, 2.0/30.0, 0.3375)
	
	if is_equal_approx(old_zoom, new_zoom):
		return
	
	var mouse_before = cam.get_global_mouse_position()
	cam.zoom = Vector2(new_zoom, new_zoom)
	var mouse_after = cam.get_global_mouse_position()
	
	cam.position += (mouse_before - mouse_after)
