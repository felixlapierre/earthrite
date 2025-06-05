extends StrEffect
class_name RegrowEffect

var listener: Listener

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new(timing, func(args: EventArgs):
		var seed = args.specific.harvest_args.seed.copy()
		seed.yld += strength
		args.specific.tile.plant_seed(seed)
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return "Regrow " + str(strength)

func get_long_description():
	return Helper.get_long_description_type(Enums.EffectType.Regrow, strength)

func get_type():
	return Enums.EffectType.Plant

func copy():
	return RegrowEffect.new().assign(self)
