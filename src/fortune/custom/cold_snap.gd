extends Fortune
class_name ColdSnap

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart

var texture_display = load("res://assets/fortune/snowflake.png")

func _init() -> void:
	super("Cold Snap", FortuneType.BadFortune, "Plants do not grow at the end of this turn.", -1, texture_display)

func register_fortune(event_manager: EventManager):
	#await popup_callback.call(true)
	Global.BLOCK_GROW = true
	#popup_callback.call(false)

func unregister_fortune(event_manager: EventManager):
	Global.BLOCK_GROW = false
