extends CanvasLayer

@onready var h_box = $MarginContainer/MarginContainer/ScrollContainer/HBoxContainer

signal item_clicked(item: Building)

var shop_items: Array[Building] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_items()
	_fill_shop_with_items()


func _load_items() -> void:
	for building: Building in BuildingRegistry._map.values():
		shop_items.append(building)


func _fill_shop_with_items() -> void:
	for child in h_box.get_children():
		child.queue_free()
		
	for item in shop_items:
		var card: ShopItemCard = Const.Shop.ShopCard.instantiate()
		card.setup(item)
		card.item_clicked.connect(_on_item_clicked)
		h_box.add_child(card)


func _on_item_clicked(item: Building) -> void:
	SimpleLogger.trace("ShopItem clicked: %s" % item)
	item_clicked.emit(item)
