extends Node2D

@onready var tilemap = $TileMapLayer
var noise = FastNoiseLite.new()
var width = 100
var height = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.05
	
	generate_map()
	
func generate_map():
	for x in range(width):
		for y in range(height):
			var n = noise.get_noise_2d(x, y)
			var atlas = Vector2i(0,0)

			if n < -0.3:
				atlas = Vector2i(0,0)
			elif n < -0.1:
				atlas = Vector2i(1,0)
			elif n < 0.4:
				atlas = Vector2i(2,0)
			else:
				atlas = Vector2i(3,0)
			
			tilemap.set_cell(Vector2i(x,y), 0, atlas)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
