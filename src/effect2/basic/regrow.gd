extends StrEffect
class_name RegrowEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnPlantHarvest, true, Enums.EffectType.Regrow, "Regrow")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var seed = args.specific.harvest_args.seed.copy()
		seed.yld += strength
		await args.specific.tile.plant_seed(seed)
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return "Regrow" + (highlight(" " + str(strength)) if strength != 0 else "")

func get_long_description():
	return Helper.get_long_description_type(Enums.EffectType.Regrow, strength)

func copy():
	return RegrowEffect.new().assign(self)
