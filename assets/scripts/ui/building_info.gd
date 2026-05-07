extends CanvasLayer

signal destroy_building(positions: Array[Vector2i])

var images_mapper: Dictionary = {
	"HQ": load("res://assets/images/icons/HQ.svg"),
	"Factory": load("res://assets/images/icons/Factory.svg")
}
var text_mapper: Dictionary = {
	"HQ": "This is are your Headquarters. \nFrom here you operate everything.",
	"Factory": "One of your factories. \nGives you 5$ per second"
}

var data: GameSaveData
var current_selected_index: int

func set_display_building(index: int) -> void:
	current_selected_index = index
	
	var label: String = data.building_data.get(current_selected_index)["label"]
	$MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Label.text = label
	$MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = images_mapper[label]
	$MarginContainer/MarginContainer/VBoxContainer/Label2.text = text_mapper[label]


func _on_destroy_pressed() -> void:
	SimpleLogger.info("Destroy Building Index <%s>" % current_selected_index)
	var positions: Array[Vector2i] = data.building_data.get(current_selected_index)["positions"]
	data.building_data.remove_at(current_selected_index)
	destroy_building.emit(positions)
	hide()


func _on_close_pressed() -> void:
	hide()
