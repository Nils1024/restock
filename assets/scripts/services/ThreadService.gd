extends Node

var _pool: Array[Thread] = []
var _queue: Array[Callable] = []
var _results: Dictionary = {}
var _active: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func schedule_task(task: Callable) -> void:
	pass
