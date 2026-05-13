class_name Building
extends Resource

@export var label: String = ""
@export var description: String = ""
@export var image: CompressedTexture2D
@export var price: int = 0
@export var upkeep: int = 5
@export var drag: bool = false
@export var tiles: Array[BuildingTile] = []
@export var behaviors: Array[BuildingBehavior] = []
@export var conditions: Array[PlacementCondition] = []

func can_place(ctx: PlacementContext) -> bool:
	for condition in conditions:
		if not condition.is_valid(ctx):
			return false
		
	return true


func tick(ctx: BuildingTickContext) -> void:
	for behavior in behaviors:
		behavior.tick(ctx)
