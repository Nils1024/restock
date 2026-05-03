extends CanvasLayer

const ShopCard = preload("res://assets/scenes/util/ui/ShopItemCard.tscn")
const SHOP_ITEMS_PATH = "res://assets/data/shop_items/"

@onready var h_box = $MarginContainer/MarginContainer/ScrollContainer/HBoxContainer

var shop_items: Array[ShopItem] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_items()
	_fill_shop_with_items()


func _load_items() -> void:
	var files: Array = Array(DirAccess.get_files_at(SHOP_ITEMS_PATH))
	for file in files.filter(func(f: String): return f.ends_with(".tres")):
		var item = load(SHOP_ITEMS_PATH + file) as ShopItem
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
	SimpleLogger.trace("Item clicked: %s" % item)
