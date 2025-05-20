extends Fortune
class_name MultiplyRitualTarget

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var image = preload("res://assets/custom/YellowMana.png")

func _init(strength: float = 1.0) -> void:
	super("Ritual Disruption 2", FortuneType.BadFortune, "Increase ritual target by {STRENGTH}%", 0, image, strength * 100)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var increase = strength
		args.turn_manager.ritual_counter += args.turn_manager.ritual_counter * strength / 100
		args.turn_manager.total_ritual += args.turn_manager.total_ritual * strength / 100
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
