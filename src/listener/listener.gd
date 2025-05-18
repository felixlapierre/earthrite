extends Node

class_name Listener

var id: String
var type: EventManager.EventType
var callback: Callable
var disabled: bool

func _init(p_id = "", p_type = EventManager.EventType.BeforeTurnStart, p_callback = null):
	id = p_id
	type = p_type
	callback = p_callback
	disabled = false

func invoke(args: EventArgs):
	if !disabled:
		callback.call(args)

func disable():
	disabled = true
