extends StrEffect
class_name DrawCardEffect

var listener: Listener

@export var timing: EventManager.EventType
@export var seed: bool

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
	return "Draw " + highlight(str(strength)) + " card(s)"

func get_type():
	return Enums.EffectType.Draw

func copy():
	return DrawCardEffect.new().assign(self)
