extends CanvasLayer

const ShopCard = preload("res://assets/scenes/util/ui/ShopItemCard.tscn")
const SHOP_ITEMS_PATHS = [
	"res://assets/data/shop_items/HQ.tres"
]

@onready var h_box = $MarginContainer/MarginContainer/ScrollContainer/HBoxContainer

signal item_clicked(item: ShopItem)

var shop_items: Array[ShopItem] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_items()
	_fill_shop_with_items()


func _load_items() -> void:
	for path in SHOP_ITEMS_PATHS:
		var item: ShopItem = load(path)
		if item:
			shop_items.append(item)


func _fill_shop_with_items() -> void:
	for child in h_box.get_children():
		child.queue_free()
		
	for item in shop_items:
		var card: ShopItemCard = ShopCard.instantiate()
		card.setup(item)
		card.item_clicked.connect(_on_item_clicked)
		h_box.add_child(card)


func _on_item_clicked(item: ShopItem) -> void:
	SimpleLogger.trace("ShopItem clicked: %s" % item)
	item_clicked.emit(item)
