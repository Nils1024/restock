extends Node

@export var buildings: Array[Building] = []

var _map: Dictionary = {}

func _ready() -> void:
	for building in buildings:
		_map[building.label] = building


func get_by_label(label: String) -> Building:
	return _map.get(label, null)
