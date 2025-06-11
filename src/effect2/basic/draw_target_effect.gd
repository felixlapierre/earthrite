extends StrEffect
class_name DrawTargetEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Draw, "DrawTargetEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var target = args.specific.tile
		var seed = target.seed.copy()
		seed.effects2.append(load("res://src/effect2/basic/data/fleeting_effect.tres"))
		for i in range(strength):
			args.cards.draw_specific_card_from(seed.copy(), target.position)
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	var copy = "[color=gold]Fleeting[/color] copy" if strength == 1 else "[color=gold]Fleeting[/color] copies"
	return "Add " + highlight(str(strength)) + copy + " of target plant's seed to your hand"

func copy():
	return DrawTargetEffect.new().assign(self)
