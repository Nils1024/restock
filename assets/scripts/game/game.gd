extends Node2D

class_name Game

@onready var cam: Camera2D = $Camera2D
@onready var tilemap: TileMapLayer = $Ground
@onready var world_manager: WorldManager = $WorldManager
@onready var building_manager: BuildingManager = $BuildingManager

var data: GameSaveData
var _last_center: Vector2i = Vector2i.ZERO
var _last_zoom: float = 0.0
var _save_timer: Timer = Timer.new()

func _enter_tree() -> void:
	if data == null:
		push_error("Data is null. Set it before adding this object to the SceneTree")
		queue_free()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	building_manager.data = data
	building_manager.place_saved_buildings()
	AudioService.stop_audio(SoundEffect.SOUND_EFFECT_TYPE.IDLE_MUSIC_1, true, 3)
	world_manager.noise.initialize(data.generation_seed)
	_save_timer.wait_time = Const.Save.AUTO_SAVE_PERIOD_IN_SEC
	_save_timer.one_shot = false
	_save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(_save_timer)
	_save_timer.start()
	cam.update_bounds()
	$UI/Profil/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Label.text = data.name
	$UI/Profil/MarginContainer/MarginContainer/HBoxContainer/PanelContainer/TextureRect.texture_normal = load("res://assets/images/avatars/Avatar %d.svg" % (data.selected_avatar_index + 1))
	$UI/Shop.item_clicked.connect($BuildingManager.on_item_clicked)
	$BuildingManager.income_updated.connect(_update_money_label)
	_update_money_label()
	
	# Tutorial
	if not data.tutorial_played:
		$Tutorial.start()
		$Tutorial.tutorial_completed.connect(func() -> void: 
			data.tutorial_played = true	
			_on_save_timer_timeout()
		)
	
	# Transition
	$FadeTransition/AnimationPlayer.play("Fade_out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var center = tilemap.local_to_map(cam.get_screen_center_position())
	var zoom_changed = abs(cam.zoom.x - _last_zoom) > 0.0001
	
	if center != _last_center or zoom_changed:
		var radius = cam.get_chunk_radius()
		world_manager.update_visible_chunks(center, radius + 2)
		world_manager.cleanup_distant_chunks(center, radius + 3)
		_last_center = center
		_last_zoom = cam.zoom.x
		cam.update_bounds()


func _unhandled_input (event: InputEvent) -> void:
	# Ingame menu
	if Input.is_action_just_pressed("esc"):
		$UI/IngameMenu.visible = not $UI/IngameMenu.visible
		$UI/IngameMenu/HowToPlay.hide()
		$UI/IngameMenu/SettingsMenu.hide()
		
	if $UI/IngameMenu.visible:
		return
	
	$BuildingManager.handle_input(event)
	
	cam.handle_input(event)


func _exit_tree() -> void:
	_save_timer.stop()
	_on_save_timer_timeout()


func _on_save_timer_timeout() -> void:
	SimpleLogger.debug("Game saved")
	DataService.update(data.id, data)
	
func _update_money_label() -> void:
	$UI/Money/MarginContainer/MarginContainer/HBoxContainer/Label.text = str(data.money)
