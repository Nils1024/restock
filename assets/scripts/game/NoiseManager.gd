extends Node

class_name NoiseManager

var elevation: Noise
var temperature: Noise
var humidity: Noise

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var base_seed: int = randi()
	
	elevation = _create_noise(base_seed, 0.05, 4)
	temperature = _create_noise(base_seed + 1, 0.02, 3)
	humidity = _create_noise(base_seed + 2, 0.025, 3)

func _create_noise(noise_seed: int, frequency: float, octaves: int) -> Noise:
	var noise: Noise = FastNoiseLite.new() 
	
	noise.seed = noise_seed
	noise.frequency = frequency
	noise.fractal_octaves = octaves
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2.0
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	return noise

func get_elevation(x: float, y: float) -> float:
	return elevation.get_noise_2d(x * 0.08, y * 0.08)
	
func get_temperature(x: float, y: float) -> float:
	return temperature.get_noise_2d(x * 0.01, y * 0.01)
	
func get_humidity(x: float, y: float) -> float:
	return humidity.get_noise_2d(x * 0.01, y * 0.01)
