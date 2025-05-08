extends Fortune
class_name EndTurnBurn

var callable
var obliviate_texture = preload("res://assets/enhance/obliviate.png")
func _init() -> void:
	super("Thoughtless", FortuneType.BadFortune, "On turn end: Burn rightmost card in hand", 2, obliviate_texture)

func register_fortune(event_manager: EventManager):
	callable = func(args: EventArgs):
		await popup_callback.call(true)
		args.cards.obliviate_rightmost()
		popup_callback.call(false)
	event_manager.register_listener(EventManager.EventType.BeforeGrow, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeGrow, callable)
