class_name ConditionNotOnMountain
extends PlacementCondition

func is_valid(ctx: PlacementContext) -> bool:
	for pos in ctx.positions:
		var atlas := ctx.world_manager._get_tile_atlas(pos.x, pos.y)
		if atlas == Vector2i(0, 2):
			return false
	
	return true
