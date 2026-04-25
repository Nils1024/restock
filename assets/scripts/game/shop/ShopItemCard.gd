extends PanelContainer

class_name ShopItemCard

signal item_clicked(item: ShopItem)

var item: ShopItem

func setup(item: ShopItem) -> void:
	self.item = item
	$VBoxContainer/PriceContainer/Price.text = str(item.price)
	$NameContainer/Name.text = item.label


func _on_buy_button_pressed() -> void:
	item_clicked.emit(item)
