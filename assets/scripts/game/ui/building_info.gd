extends CanvasLayer

signal destroy_building(positions: Array[Vector2i])

var data: GameSaveData
var selected_entry: BuildingSaveEntry = null

func set_display_building(entry: BuildingSaveEntry) -> void:
	selected_entry = entry
	
	var label: String = selected_entry.building.label
	$MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Label.text = label
	$MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = selected_entry.building.image
	$MarginContainer/MarginContainer/VBoxContainer/Label2.text = selected_entry.building.description


func _on_destroy_pressed() -> void:
	SimpleLogger.info("Destroy Building <%s> at <%s>" % [selected_entry.building.label, selected_entry.building.tiles])
	data.building_data.erase(selected_entry)
	destroy_building.emit(selected_entry.positions)
	hide()


func _on_close_pressed() -> void:
	hide()
