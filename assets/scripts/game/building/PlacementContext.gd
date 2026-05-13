class_name PlacementContext
extends RefCounted

var positions: Array[Vector2i]
var world_manager: WorldManager
var building_data: Array[BuildingSaveEntry]

func _init(p_positions: Array[Vector2i], p_world_manager: WorldManager, p_building_data: Array[BuildingSaveEntry]) -> void:
	positions = p_positions
	world_manager = p_world_manager
	building_data = p_building_data
