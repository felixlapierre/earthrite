extends StrEffect
class_name GrowEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Grow, "GrowEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		for i in range(strength):
			await args.specific.tile.grow_one_week()
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return get_timing_text() + "Grow %s plants by %s week(s)" % [str(size), highlight(str(strength))]

func copy():
	return GrowEffect.new().assign(self)
