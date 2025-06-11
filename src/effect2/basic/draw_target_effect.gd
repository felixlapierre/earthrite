extends StrEffect
class_name DrawTargetEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Draw, "DrawEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var target = args.specific.tile
		for i in range(strength):
			args.cards.drawcard_specific_card_from(target.seed.copy(), target.position)
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	var copy = " copy" if strength == 1 else " copies"
	return "Add " + highlight(str(strength)) + copy + " of target plant's seed to your hand"

func get_type():
	return Enums.EffectType.Draw

func copy():
	return DrawCardEffect.new().assign(self)
