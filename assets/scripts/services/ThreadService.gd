extends Node

class Job:
	var id: int
	var callable: Callable
	var on_complete: Callable
	
class Result:
	var result: Variant
	var on_complete: Callable

var _threads: Array[Thread] = []
var _queue: Array[Job] = []
var _results: Array[Result] = []

var _queue_mutex: Mutex = Mutex.new()
var _result_mutex: Mutex = Mutex.new()
var _semaphore: Semaphore = Semaphore.new()

var _next_id: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Const.Config.MAX_THREADS:
		var thread: Thread = Thread.new()
		_threads.append(thread)
		thread.start(_worker)

func schedule_task(task: Callable, on_complete: Callable) -> int:
	var job: Job = Job.new()
	
	job.id = _next_id
	_next_id += 1
	
	job.callable = task
	job.on_complete = on_complete
	
	_queue_mutex.lock()
	_queue.append(job)
	_queue_mutex.unlock()
	
	_semaphore.post()
	return job.id
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_result_mutex.lock()
	var is_ready = _results.duplicate()
	_results.clear()
	_result_mutex.unlock()
	
	for entry in is_ready:
		entry.on_complete.call(entry.result)
	
func _worker() -> void:
	while true:
		_semaphore.wait()
		
		_queue_mutex.lock()
		if _queue.is_empty():
			_queue_mutex.unlock()
			continue
			
		var job: Job = _queue.pop_front()
		_queue_mutex.unlock()
		
		var result = job.callable.call()
		
		_result_mutex.lock()
		var resultObj: Result = Result.new()
		resultObj.result = result
		resultObj.on_complete = job.on_complete
		_results.append(resultObj)
		_result_mutex.unlock()
