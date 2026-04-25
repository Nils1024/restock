extends CanvasLayer

const ShopCard = preload("res://assets/scenes/util/ui/ShopItemCard.tscn")

@onready var h_box = $MarginContainer/MarginContainer/ScrollContainer/HBoxContainer

var shop_items: Array[ShopItem] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_items()
	_fill_shop_with_items()


func _load_items() -> void:
	var files: Array = Array(DirAccess.get_files_at("res://assets/shop_items/"))
	for file in files.filter(func(f: String): return f.ends_with(".tres")):
		var item = load("res://assets/shop_items/" + file) as ShopItem
		if item:
			shop_items.append(item)

func _fill_shop_with_items() -> void:
	for child in h_box.get_children():
		child.queue_free()
		
	for item in shop_items:
		var card: ShopItemCard = ShopCard.instantiate()
		card.setup(item)
		card.item_clicked.connect(_on_item_purchased)
		h_box.add_child(card)


func _on_item_purchased(item: ShopItem) -> void:
	pass
