extends Node

class_name Listener

var id: String
var type: EventManager.EventType
var callback: Callable
var disabled: bool

func _init(p_type = EventManager.EventType.BeforeTurnStart, p_callback = null):
	id = str(randi())
	type = p_type
	callback = p_callback
	disabled = false

func invoke(args: EventArgs):
	if !disabled:
		await callback.call(args)

func disable():
	disabled = true
