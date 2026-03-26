extends Node2D

@onready var tilemap = $TileMapLayer
var noise = FastNoiseLite.new()

var mouse_press_start = Vector2.ZERO
var is_dragging = false
var drag_threshold = 10

var tile_radius_around_camera = 150
var last_center = Vector2i.ZERO
var generated = {}
var loaded_chunks = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2.0
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
			
func is_near_water(x,y):
	for dx in [-1,0,1]:
		for dy in [-1,0,1]:
			if dx == 0 and dy == 0:
				continue
			
			var n = noise.get_noise_2d((x+dx)*0.08, (y+dy)*0.08)
			if n < -0.4:
				return true
			
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cam = $Camera2D
	var center = tilemap.local_to_map(cam.get_screen_center_position())
	
	if center != last_center:
		update_map(center)
		last_center = center
		
	cleanup(center)
		
func update_map(center: Vector2i):
	var radius = tile_radius_around_camera
	
	for x in range(center.x - radius, center.x + radius):
		for y in range(center.y - radius, center.y + radius):
			
			var key = Vector2i(x,y)
			
			if generated.has(key):
				continue
			
			var n = noise.get_noise_2d(x * 0.08, y * 0.08)
			
			var atlas = get_tile(n, x, y)
			
			tilemap.set_cell(key, 0, atlas)
			generated[key] = true
			
func get_tile(n, x, y):
	if n < -0.4:
		return Vector2i(2,0)
	elif is_near_water(x,y):
		return Vector2i(1,0)
	elif n < 0.5:
		return Vector2i(0,0)
	else:
		return Vector2i(3,0)
		
func cleanup(center):
	var radius = tile_radius_around_camera
	
	for key in generated.keys():
		if key.distance_to(center) > radius * 1.5:
			tilemap.erase_cell(key)
			generated.erase(key)
	
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
		$Camera2D.position += delta * 10.0
	
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
				$Camera2D.position -= event.relative * 10
		
	# Zoom in and out
	if Input.is_action_just_pressed("zoom_in"):
		zoom_camera(1.0 / 1.5)
	if Input.is_action_just_pressed("zoom_out"):
		zoom_camera(1.5)
		
func zoom_camera(factor):
	var cam = $Camera2D
	var mouse_before = cam.get_global_mouse_position()
	cam.zoom *= Vector2(factor, factor)
	var mouse_after = cam.get_global_mouse_position()
	cam.position += (mouse_before - mouse_after)
