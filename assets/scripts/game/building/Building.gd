class_name Building
extends Resource

@export var label: String = ""
@export var description: String = ""
@export var image: CompressedTexture2D
@export var price: int = 0
@export var upkeep: int = 5
@export var drag: bool = false
@export var behaviors: Array[BuildingBehavior] = []
@export var conditions: Array[PlacementCondition] = []

func to_dict() -> Dictionary:
	return {
		"label": label,
		"description": description,
		"price": price,
		"upkeep": upkeep
	}
