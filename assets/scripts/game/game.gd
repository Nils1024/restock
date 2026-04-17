extends Node2D

@onready var cam = $Camera2D
@onready var tilemap = $TileMapLayer
@onready var world_manager: WorldManager = $WorldManager

var _last_center: Vector2i = Vector2i.ZERO
var _last_zoom: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam.update_bounds()
	
	await UtilityService.wait(1)
	$UI/Tutorial.offset = Vector2(400, 200)
	$UI/Tutorial.add_text_to_queue("Welcome to Restock")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var center = tilemap.local_to_map(cam.get_screen_center_position())
	var zoom_changed = abs(cam.zoom.x - _last_zoom) > 0.0001
	
	if center != _last_center or zoom_changed:
		var radius = cam.get_chunk_radius()
		world_manager.update_visible_chunks(center, radius + 2)
		world_manager.cleanup_distant_chunks(center, radius + 3)
		_last_center = center
		_last_zoom = cam.zoom.x
		cam.update_bounds()
		
func _input(event: InputEvent) -> void:
	# Ingame menu
	if Input.is_action_just_pressed("esc"):
		$UI/IngameMenu.visible = not $UI/IngameMenu.visible
		
	if $UI/IngameMenu.visible:
		return
	
	cam.handle_input(event)
