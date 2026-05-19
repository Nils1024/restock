class_name BuildingSaveEntry
extends Resource

@export var building: Building
@export var positions: Array[Vector2i] = []

func to_dict() -> Dictionary:
	return {
		"label": building.label,
		"positions": positions.map(func(p: Vector2i) -> Array: return [p.x, p.y])
	}
	
static func from_dict(d: Dictionary) -> BuildingSaveEntry:
	var entry: BuildingSaveEntry = BuildingSaveEntry.new()
	
	entry.building = BuildingRegistry.get_by_label(d["label"])
	
	for p in d["positions"]:
		entry.positions.append(Vector2i(p[0], p[1]))
	
	return entry
