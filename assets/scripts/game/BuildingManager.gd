extends Node

class_name BuildingManager

@export var world_manager: WorldManager
@export var buildings_tilemap: TileMapLayer
@export var preview_tilemap: TileMapLayer
@export var build_controls_box: HBoxContainer
@export var not_enough_money_label: Label

signal shop_item_placed(item: ShopItem)
signal income_updated()

var _pending_item: ShopItem = null
var _rotation: int = 0

var _drag_start: Vector2i = Vector2i(-1, -1)
var _is_dragging: bool = false

var _income_timer: float = 0.0
# Every second
const INCOME_INTERVAL: float = 1.0

var data: GameSaveData
var _timer: Timer = null

func place_saved_buildings() -> void:
	for building in data.building_data:
		var building_name: String = building.get("label")
		var positions: Array = building.get("positions")
		var item_data: Dictionary = Const.Building.BUILDING_DICT[building_name]
		
		for i in range(positions.size()):
			var pos: Vector2i = positions[i]
			var atlas: Vector2i = item_data["tiles"][i]["atlas"]
			buildings_tilemap.set_cell(pos, 0, atlas)
		
		SimpleLogger.trace("Restored <%s> at <%s>" % [building_name, positions])


func _process(delta: float) -> void:
	_tick_income(delta)
	_update_preview()


func _tick_income(delta: float) -> void:
	_income_timer += delta
	if _income_timer < INCOME_INTERVAL:
		return
	_income_timer -= INCOME_INTERVAL
	
	var total: int = 0
	for entry in data.building_data:
		var label: String = entry["label"]
		var income: int = Const.Building.BUILDING_DICT[label].get("income", 0)
		total += income
		
	if total != 0:
		data.money += total
		income_updated.emit()


func _update_preview() -> void:
	preview_tilemap.clear()
	
	if _pending_item == null:
		return
		
	var item_data: Dictionary = Const.Building.BUILDING_DICT[_pending_item.label]
	var tile_pos: Vector2i = _get_mouse_tile_pos()
	
	if item_data["drag"]:
		# TODO: Drag for streets
		pass
	else:
		for tile in item_data["tiles"]:
			var rotated_offset: Vector2i = _rotate_offset(tile["offset"])
			preview_tilemap.set_cell(tile_pos + rotated_offset, 0, tile["atlas"])

func on_item_clicked(item: ShopItem) -> void:
	_pending_item = item
	_rotation = 0
	_is_dragging = false
	_drag_start = Vector2i(-1, -1)
	build_controls_box.show()


func handle_input(event: InputEvent) -> void:
	if _pending_item == null:
		return
		
	var item_data: Dictionary = Const.Building.BUILDING_DICT[_pending_item.label]
	var is_drag: bool = item_data["drag"]
		
	if not is_drag and event.is_action_pressed("rotate"):
		_rotation = (_rotation + 1) % 4
		return
		
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
			if data.money >= _pending_item.price:
				_place_building(_pending_item)
			else:
				not_enough_money_label.show()
				
				_timer = Timer.new()
				_timer.wait_time = 2
				_timer.one_shot = true
				_timer.timeout.connect(not_enough_money_label.hide)
				_timer.timeout.connect(_timer.queue_free)
				add_child(_timer)
				_timer.start()
			
			_cancel_placement()
			
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()


func _get_mouse_tile_pos() -> Vector2i:
	return buildings_tilemap.local_to_map(buildings_tilemap.get_local_mouse_position())


func _is_place_free(building_positions: Array[Vector2i]) -> bool:
	for pos in building_positions:
		var world_atlas: Vector2i = world_manager._get_tile_atlas(pos.x, pos.y)
		if world_atlas == Vector2i(0, 2) \
			or world_atlas == Vector2i(0, 1):
			SimpleLogger.info("Placing stopped - invalid underground")
			return false
		
		for building in data.building_data:
			if pos in building["positions"]:
				SimpleLogger.info("Placing stopped - already occupied")
				return false
	
	return true


func _place_building(item: ShopItem) -> void:
	var tile_pos: Vector2i = _get_mouse_tile_pos()
	var item_data: Dictionary = Const.Building.BUILDING_DICT[item.label]
	var positions: Array[Vector2i] = []
	
	for tile in item_data["tiles"]:
		positions.append(tile_pos + _rotate_offset(tile["offset"]))
		
	if not _is_place_free(positions):
		return
	
	for i in range(positions.size()):
		var pos: Vector2i = positions[i]
		var atlas: Vector2i = item_data["tiles"][i]["atlas"]
		buildings_tilemap.set_cell(pos, 0, atlas)
	
	data.building_data.append({
		"label": item.label,
		"positions": positions
	})
	
	data.money -= _pending_item.price
	income_updated.emit()
	
	SimpleLogger.info("Placing <%s> at <%s>" % [item.label, positions])
	shop_item_placed.emit(item)


func _cancel_placement() -> void:
	_pending_item = null
	_is_dragging = false
	_drag_start = Vector2i(-1, -1)
	build_controls_box.hide()


func _rotate_90(offset: Vector2i) -> Vector2i:
	return Vector2i(offset.y, -offset.x)


func _rotate_offset(offset: Vector2i) -> Vector2i:
	var result = offset
	
	for i in range(_rotation):
		result = _rotate_90(result)
		
	return result


func _on_building_destroyed(positions: Array[Vector2i]) -> void:
	for pos in positions:
		buildings_tilemap.erase_cell(pos)
