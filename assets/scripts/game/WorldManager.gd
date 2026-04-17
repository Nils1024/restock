extends Node

class_name WorldManager

@export var tilemap: TileMapLayer
@export var noise: NoiseManager

enum Biome {
	SNOW,
	TUNDRA,
	DESERT,
	FOREST,
	GRASS
}

signal chunk_loaded(chunk_pos: Vector2i)
signal chunk_unloaded(chunk_pos: Vector2i)

var _loaded_chunks: Dictionary = {}
var _chunk_cache: Dictionary = {}
var _chunk_queue: Array[Vector2i] = []
var _pending_jobs: Dictionary = {}

func update_visible_chunks(center_tile: Vector2i, load_radius: int) -> void:
	var center_chunk = _tile_to_chunk(center_tile)
	
	for cx in range(center_chunk.x - load_radius, center_chunk.x + load_radius + 1):
		for cy in range(center_chunk.y - load_radius, center_chunk.y + load_radius + 1):
			var chunk_pos = Vector2i(cx, cy)
			
			if _loaded_chunks.has(chunk_pos) or _pending_jobs.has(chunk_pos):
				continue
				
			if not _chunk_queue.has(chunk_pos):
				_chunk_queue.append(chunk_pos)
	
	_chunk_queue.sort_custom(func(a, b):
		return a.distance_to(center_chunk) < b.distance_to(center_chunk)
	)
	
	_flush_queue()

func cleanup_distant_chunks(center_tile: Vector2i, unload_radius: int) -> void:
	var center_chunk = _tile_to_chunk(center_tile)
	
	for chunk in _loaded_chunks.keys().duplicate():
		if chunk.distance_to(center_chunk) > unload_radius:
			_unload_chunk(chunk)
			
func _flush_queue() -> void:
	while not _chunk_queue.is_empty():
		var chunk_pos = _chunk_queue.pop_front()
		var job_id = ThreadService.schedule_task(
			_generate_chunk.bind(chunk_pos),
		 	_on_chunk_ready.bind(chunk_pos)
		)
		_pending_jobs[chunk_pos] = job_id

func _generate_chunk(chunk_pos: Vector2i) -> Array:
	var result: Array = []
	
	for x in range(Const.World.CHUNK_SIZE):
		for y in range(Const.World.CHUNK_SIZE):
			var wx = chunk_pos.x * Const.World.CHUNK_SIZE + x
			var wy = chunk_pos.y * Const.World.CHUNK_SIZE + y
			
			if wx < Const.World.MIN_WORLD_COORD or wx > Const.World.MAX_WORLD_COORD or wy < Const.World.MIN_WORLD_COORD or wy > Const.World.MAX_WORLD_COORD:
				continue
			
			var atlas = _get_tile_atlas(wx, wy)
			result.append([Vector2i(wx, wy), atlas])
	
	return result
	
func _on_chunk_ready(result: Array, chunk_pos: Vector2i) -> void:
	_pending_jobs.erase(chunk_pos)
	
	if result.is_empty():
		return
		
	_chunk_cache[chunk_pos] = result
	_apply_chunk(result)
	_loaded_chunks[chunk_pos] = true
	chunk_loaded.emit(chunk_pos)
	
func _apply_chunk(data: Array) -> void:
	for cell in data:
		tilemap.set_cell(cell[0], 0, cell[1])
	
func _unload_chunk(chunk_pos: Vector2i) -> void:
	if not _chunk_cache.has(chunk_pos):
		return
	
	for cell in _chunk_cache[chunk_pos]:
		tilemap.erase_cell(cell[0])
	
	_loaded_chunks.erase(chunk_pos)
	_chunk_cache.erase(chunk_pos)
	chunk_unloaded.emit(chunk_pos)
	
func _get_tile_atlas(x, y) -> Vector2i:
	var elevation = noise.get_elevation(x, y)
	
	if elevation < -0.4:
		return Vector2i(2,0)
	elif _is_near_water(x,y):
		return Vector2i(1,0)
	elif elevation < 0.5:
		return Vector2i(0,0)
	else:
		return Vector2i(3,0)
	
func _is_near_water(x,y) -> bool:
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
				
			var nx = x + dx
			var ny = y + dy
			
			if nx < Const.World.MIN_WORLD_COORD or nx > Const.World.MAX_WORLD_COORD or ny < Const.World.MIN_WORLD_COORD or ny > Const.World.MAX_WORLD_COORD:
				continue
			
			if noise.get_elevation((x+dx), (y+dy)) < -0.4:
				return true
				
	return false
	
func get_biome(x: int, y: int) -> Biome:
	var temperature := noise.get_temperature(x, y)
	
	if temperature < -0.3:
		return Biome.SNOW
	else:
		return Biome.GRASS
	
func _tile_to_chunk(tile: Vector2i) -> Vector2i:
	return Vector2i(
		floori(float(tile.x) / Const.World.CHUNK_SIZE),
		floori(float(tile.y) / Const.World.CHUNK_SIZE))
