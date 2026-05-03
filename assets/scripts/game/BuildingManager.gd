extends Node

@export var buildings_tilemap: TileMapLayer
@export var preview_tilemap: TileMapLayer

const building_dict: Dictionary = {
	"HQ": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2),
		Vector2i(1, 0), Vector2i(1, 1)]
}
var _pending_item: ShopItem = null

func _process(delta: float) -> void:
	preview_tilemap.clear()
	
	if _pending_item == null:
		return
		
	var tile_pos = _get_mouse_tile_pos()
	
	for offset in building_dict[_pending_item.label]:
		preview_tilemap.set_cell(tile_pos + offset, 0, Vector2i(0, 0))


func on_item_clicked(item: ShopItem) -> void:
	_pending_item = item


func handle_input(event: InputEvent) -> void:
	if _pending_item == null:
		return
		
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
			_place_building(_pending_item)
			_pending_item = null
			
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT:
			_pending_item = null


func _get_mouse_tile_pos() -> Vector2i:
	return buildings_tilemap.local_to_map(buildings_tilemap.get_local_mouse_position())


func _place_building(item: ShopItem) -> void:
	var tile_pos = _get_mouse_tile_pos()
	
	for offset in building_dict[item.label]:
		buildings_tilemap.set_cell(tile_pos + offset, 0, Vector2i(0, 0))
		
	SimpleLogger.info("Placing %s at %s" % [item.label, tile_pos])
