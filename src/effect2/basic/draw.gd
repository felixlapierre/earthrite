extends StrEffect
class_name DrawCardEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.Draw, "DrawEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		for i in range(strength):
			args.cards.drawcard()
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return get_timing_text() + "Draw " + highlight(str(strength)) + " card(s)"

func copy():
	return DrawCardEffect.new().assign(self)
