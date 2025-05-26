extends Fortune
class_name AddDarkThornsDeck

var dark_thorn = preload("res://src/cards/data/unique/dark_thorn.tres")
var callback_turn_start: Callable
var type_turn_start = EventManager.EventType.BeforeTurnStart

var fortune_texture = preload("res://assets/fortune/dark-thorn.png")

func _init(strength: float = 1.0) -> void:
	super("Thorns", Fortune.FortuneType.BadFortune, "Turn start: Add {STRENGTH} Dark Thorn to your deck", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	callback_turn_start = func(args: EventArgs):
		for i in range(strength):
			args.cards.deck_cards.append(dark_thorn.copy())
	event_manager.register_listener(type_turn_start, callback_turn_start)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(type_turn_start, callback_turn_start)
