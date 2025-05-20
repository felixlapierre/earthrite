extends Fortune
class_name IncreaseBlightStrength

var fortune_texture = preload("res://assets/fortune/cataclysm.png")

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart

func _init(strength: float = 1.0) -> void:
	super("Cataclysm", Fortune.FortuneType.BadFortune, "Blight attack strength increased by {STR_PER}", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if event_manager.turn_manager.week == 1:
			await popup_callback.call(true)
			await popup_callback.call(false)
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
