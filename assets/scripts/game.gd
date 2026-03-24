extends Node2D

@onready var tilemap = $TileMapLayer
var noise = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2.0
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	generate_map()
	
func generate_map():
	var width = 200
	var height = 200
	var scale = 0.08
	
	var map = []
	
	var min_val = 9999.0
	var max_val = -9999.0

	for x in range(width):
		map.append([])
		for y in range(height):
			var n = noise.get_noise_2d(x * scale, y * scale)
			map[x].append(n)
			
			min_val = min(min_val, n)
			max_val = max(max_val, n)

	for x in range(width):
		for y in range(height):
			var n = (map[x][y] - min_val) / (max_val - min_val)
			var atlas = Vector2i(0,0)
			
			if n < 0.30:
				atlas = Vector2i(2,0)
			elif is_near_water(map,x,y,min_val,max_val):
				atlas = Vector2i(1,0)
			elif n < 0.75:
				atlas = Vector2i(0,0)
			else:
				atlas = Vector2i(3,0)

			tilemap.set_cell(Vector2i(x,y), 0, atlas)
			
func is_near_water(map, x, y, min_val, max_val):
	for dx in range(-1,2):
		for dy in range(-1,2):
			if dx == 0 and dy == 0:
				continue

			var nx = x + dx
			var ny = y + dy

			if nx >= 0 and ny >= 0 and nx < map.size() and ny < map[0].size():
				var n = (map[nx][ny] - min_val) / (max_val - min_val)
				if n < 0.30:
					return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# TODO: Look at the DDA/Bresenham algorithm
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		
		var cell = $TileMapLayer.local_to_map($TileMapLayer.to_local(mouse_pos))
		print("Clicked:", cell)
		
	if Input.is_action_just_pressed("zoom_in"):
		zoom_camera(1.5)
	if Input.is_action_just_pressed("zoom_out"):
		zoom_camera(1.0 / 1.5)
		
func zoom_camera(factor):
	var cam = $Camera2D
	var mouse_before = cam.get_global_mouse_position()
	cam.zoom *= Vector2(factor, factor)
	var mouse_after = cam.get_global_mouse_position()
	cam.position += (mouse_before - mouse_after)
