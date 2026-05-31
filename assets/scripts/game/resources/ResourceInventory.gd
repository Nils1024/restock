class_name ResourceInventory
extends RefCounted

var _stock: Dictionary = {}

func add(resource: GameResource, amount: int) -> void:
	_stock[resource.label] = count(resource) + amount
	
func remove(resource: GameResource, amount: int) -> void:
	var current: int = count(resource)
	if amount <= current:
		_stock[resource.label] = current - amount
	else:
		SimpleLogger.warn("Tried to remove more of <%s> than available (%s)" % [resource.label, current])
	
func has(resource: GameResource, amount: int) -> bool:
	return count(resource) >= amount
	
func count(resource: GameResource) -> int:
	return _stock.get(resource.label, 0)

func to_dict() -> Dictionary:
	return _stock.duplicate()
	
func from_dict(dict: Dictionary) -> void:
	_stock = dict.duplicate()
