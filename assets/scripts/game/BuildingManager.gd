extends Node

@export var world_manager: WorldManager
@export var buildings_tilemap: TileMapLayer
@export var preview_tilemap: TileMapLayer
@export var build_controls_box: HBoxContainer

const building_dict: Dictionary = {
	"HQ": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2),
		Vector2i(1, 0), Vector2i(1, 1)]
}
var _pending_item: ShopItem = null
var _rotation: int = 0
var data: GameSaveData

func _process(_delta: float) -> void:
	preview_tilemap.clear()
	
	if _pending_item == null:
		return
		
	var tile_pos = _get_mouse_tile_pos()
	
	for offset in building_dict[_pending_item.label].map(func(o): return _rotate_offset(o)):
		preview_tilemap.set_cell(tile_pos + offset, 0, Vector2i(0, 0))


func on_item_clicked(item: ShopItem) -> void:
	_pending_item = item
	_rotation = 0
	build_controls_box.show()


func handle_input(event: InputEvent) -> void:
	if _pending_item == null:
		return
		
	if event.is_action_pressed("rotate"):
		_rotation = (_rotation + 1) % 4
		return
		
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
			_place_building(_pending_item)
			_pending_item = null
			
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT:
			_pending_item = null
			build_controls_box.hide()


func _get_mouse_tile_pos() -> Vector2i:
	return buildings_tilemap.local_to_map(buildings_tilemap.get_local_mouse_position())


func _is_place_free(building_offsets: Array[Vector2i]) -> bool:
	var tile_pos = _get_mouse_tile_pos()
	
	for offset in building_offsets:
		var final_pos = tile_pos + offset
		if world_manager._get_tile_atlas(final_pos.x, final_pos.y) == Vector2i(0, 2):
			return false
	
	return true


func _place_building(item: ShopItem) -> void:
	var tile_pos = _get_mouse_tile_pos()
	
	var building_offsets: Array[Vector2i] = []
	building_offsets.assign(building_dict[item.label].map(func(o): return _rotate_offset(o)))
	
	if _is_place_free(building_offsets):
		for offset in building_offsets:
			buildings_tilemap.set_cell(tile_pos + offset, 0, Vector2i(0, 0))
		
	SimpleLogger.info("Placing <%s> at <%s>" % [item.label, tile_pos])


func _rotate_90(offset: Vector2i) -> Vector2i:
	return Vector2i(offset.y, -offset.x)


func _rotate_offset(offset: Vector2i) -> Vector2i:
	var result = offset
	
	for i in range(_rotation):
		result = _rotate_90(result)
		
	return result
