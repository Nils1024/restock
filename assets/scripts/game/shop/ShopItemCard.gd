extends PanelContainer

class_name ShopItemCard

signal item_clicked(item: Building)

var item: Building

func setup(shopitem: Building) -> void:
	item = shopitem
	$VBoxContainer/PriceContainer/Price.text = str(item.price)
	$NameContainer/Name.text = item.label
	$BuyButton.texture_normal = item.image
	$BuyButton.ignore_texture_size = true
	$BuyButton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	$BuyButton.custom_minimum_size = Vector2i(64, 64)
	$BuyButton.size = Vector2i(64, 64)
	$BuyButton.pressed.connect(_on_buy_button_pressed)


func _on_buy_button_pressed() -> void:
	item_clicked.emit(item)
