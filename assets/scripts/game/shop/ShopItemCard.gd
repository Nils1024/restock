extends PanelContainer

class_name ShopItemCard

signal item_clicked(item: ShopItem)

var item: ShopItem

func setup(item: ShopItem) -> void:
	self.item = item
	$VBoxContainer/PriceContainer/Price.text = str(item.price)
	$NameContainer/Name.text = item.label
	$BuyButton.texture_normal = item.image
	size = Vector2i(64, 64)
	custom_minimum_size = Vector2i(64, 64)
	


func _on_buy_button_pressed() -> void:
	item_clicked.emit(item)
